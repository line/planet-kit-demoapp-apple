import Foundation
import Combine

struct PlanetAppServerRepository {
    static let serviceId = "line-planet-call"
    static let appServerUrl = "https://voipnx-as.line-apps.com"
    static let saturnServerUrl = "https://voipnx-saturn.line-apps.com"

    private var appServerScheme: String { URL(string: Self.appServerUrl)!.scheme! }
    private var appServerHost: String { URL(string: Self.appServerUrl)!.host! }
    private let region = "JP"
    #if os(macOS)
    private let appType = "DESKTOPMAC"
    #elseif os(iOS)
    private let appType = "IOS"
    #endif

    private let apiKey = "e-Lx-xZxLXHpy0MlVudyjRAXJp1FOWN82eXIYyGyC7gmJh83U4IFQeTiaiKhvWxT5AVsuxVHztAdNUqQkXtGC0VsV2QgkQ-OuWyP57OChs-Ov_37NuTwS6sOD1Eb4PK5xQkiKoOd9nL2lqFBKqaxxg"

    enum Method: String {
        case `get` = "GET"
        case post = "POST"
    }

    enum NotificationType: String, Codable {
        case apnsvoip
        case lp
    }
    enum ServerType: String, Codable {
        case developmenet
        case production
    }

    private let notificationType: NotificationType = .lp
    private let serverType: ServerType = .production

    private let appVersion = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()

    private struct RegisterUserParam: Encodable {
        let userId: String
        let serviceId: String
        let region: String
        let displayName: String
        let apiKey: String
    }

    private struct RegisterDeviceParam: Encodable {
        let appType: String
        let appVer: String
    }

    private struct UpdateNotificationTokenParam: Encodable {
        let appType: String
        let appVer: String
        let notificationType: NotificationType
        let notificationToken: String
        let apnsServer: ServerType
    }

    private struct RegisterUserResponse: Decodable {
        let status: String
        let message: String?
        let code: Int?
        let data: ResponseData?
        let timestamp: Int64

        struct ResponseData: Decodable {
            let accessToken: String
        }
    }

    private struct RegisterDeviceResponse: Decodable {
        let status: String
        let message: String?
        let code: Int?
        let timestamp: Int64
    }

    private struct IssueGWAccessTokenResponse: Decodable {
        let status: String
        let timestamp: Int64
        let data: ResponseData

        struct ResponseData: Decodable {
            let userId: String?
            let serviceId: String?
            let gwAccessToken: String?
        }
    }

    private struct UpdateNotificationTokenResponse: Decodable {
        let status: String
        let message: String?
        let code: Int?
        let timestamp: Int64
    }

    struct PollingNotificationResponse: Decodable {
        let status: String
        let message: String?
        let code: Int?
        let data: ResponseData?
        let timestamp: Int64

        struct ResponseData: Decodable {
            let appCallType: String
            let appCalleeUID: String
            let appCallerUID: String
            let appCalleeSID: String
            let appCallerSID: String
            let appSTID: String?
            let env: String
            let appAppSvrData: String?
            let ccParam: String

            enum CodingKeys: String, CodingKey {
                case appCallType = "app_call_type"
                case appCalleeUID = "app_callee_uid"
                case appCallerUID = "app_caller_uid"
                case appCalleeSID = "app_callee_sid"
                case appCallerSID = "app_caller_sid"
                case appSTID = "app_stid"
                case env = "_env"
                case appAppSvrData = "app_app_svr_data"
                case ccParam = "cc_param"
            }
        }
    }
}

extension PlanetAppServerRepository: AppServerRepository {
    var serverUrl: String {
        PlanetAppServerRepository.saturnServerUrl
    }

    func registerDevice(user: UserAccount) async -> Bool {
        let param = RegisterDeviceParam(appType: appType, appVer: appVersion)

        guard let request = makeRequest(uri: "/v2/register_device", method: .post, accessToken: user.accessToken, param: param) else {
            return false
        }

        do {
            let response = try await sendRequest(request) as RegisterDeviceResponse
            guard response.status == "success" else {
                return false
            }
            return true
        } catch {
            AppLog.v(error)
            return false
        }
    }

    func updateNotificationToken(user: UserAccount, token: String) async -> Bool {
        let param = UpdateNotificationTokenParam(
            appType: appType,
            appVer: appVersion,
            notificationType: notificationType,
            notificationToken: token,
            apnsServer: serverType
        )

        guard let request = makeRequest(uri: "/v2/update_notification_token", method: .post, accessToken: user.accessToken, param: param) else {
            return false
        }

        do {
            let response = try await sendRequest(request) as UpdateNotificationTokenResponse
            guard response.status == "success" else {
                return false
            }
            return true
        } catch {
            AppLog.v(error)
            return false
        }
    }

    func getAccessToken(user: UserAccount) async -> String? {
        guard let request = makeRequest(uri: "/v2/access_token/issue", method: .get, accessToken: user.accessToken) else {
            return nil
        }

        do {
            let response = try await sendRequest(request) as IssueGWAccessTokenResponse

            guard response.status == "success" else {
                return nil
            }

            return response.data.gwAccessToken
        } catch {
            AppLog.v("\(#function) - \(error)")
            return nil
        }
    }

    func getNotification(user: UserAccount) async -> Result<PushMessage, NotificationError> {
        guard let request = makeRequest(uri: "/v2/notification/lp", method: .get, accessToken: user.accessToken) else {
            return .failure(.unknown)
        }

        do {
            let response = try await sendRequest(request) as PollingNotificationResponse
            guard response.status == "success", let data = response.data else {
                return .failure(.unknown)
            }
            let message = PushMessage(caller: data.appCallerSID, param: data.ccParam)
            return .success(message)
        } catch let error as ResponseError {
            switch error {
            case .httpError(let code, let message):
                AppLog.v("\(#function) - \(message)")
                return code == 503 ? .failure(.retry) : .failure(.unknown)
            default:
                AppLog.v("\(#function) - \(error.description)")
                return .failure(.unknown)
            }
        } catch {
            AppLog.v("\(#function) - \(error.localizedDescription)")
            return .failure(.unknown)
        }
    }

    var serviceId: String {
        PlanetAppServerRepository.serviceId
    }

    func registerUser(userId: String, displayName: String) async -> Result<UserAccount, RegisterUserError> {
        let requestParam = RegisterUserParam(
            userId: userId,
            serviceId: Self.serviceId,
            region: region,
            displayName: displayName,
            apiKey: apiKey
        )

        guard let request = makeRequest(uri: "/v2/register_user", method: .post, param: requestParam) else {
            return .failure(.unknown)
        }

        do {
            let response = try await sendRequest(request) as RegisterUserResponse

            guard response.status == "success", let data = response.data else {
                return .failure(.unknown)
            }

            guard let jwt = JWT.decode(token: data.accessToken), let expirationDate = jwt.payload.expiration else {
                return .failure(.unknown)
            }

            let userAccount = UserAccount(userId: userId, serviceId: serviceId, displayName: displayName, expirationDate: expirationDate, accessToken: data.accessToken)

            return .success(userAccount)
        } catch let error as ResponseError {
            switch error {
            case .httpError(let code, let message):
                if code == 409 {
                    return .failure(.userIdExist)
                }
                AppLog.v("\(#function) - \(message)")
                return .failure(.unknown)
            default:
                return .failure(.unknown)
            }
        } catch {
            AppLog.v("\(#function) - \(error.localizedDescription)")
            return .failure(.unknown)
        }
    }
}

extension PlanetAppServerRepository {
    private func makeRequest(uri: String, method: Method, accessToken: String? = nil, param: Encodable? = nil) -> URLRequest? {
        var components = URLComponents()
        components.scheme = appServerScheme
        components.host = appServerHost
        components.path = uri

        if method == .get, let param = param {
            do {
                let jsonData = try JSONEncoder().encode(param)
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    components.queryItems = jsonObject.map { key, value in
                        URLQueryItem(name: key, value: "\(value)")
                    }
                }
            } catch {
                AppLog.v("Error encoding parameters: \(error)")
                return nil
            }
        }

        guard let url = components.url else {
            AppLog.v("#demo \(#function) failed to create url")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if method == .post, let param = param {
            do {
                request.httpBody = try JSONEncoder().encode(param)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                AppLog.v("Error encoding parameters: \(error)")
                return nil
            }
        }

        return request
    }

    private enum ResponseError: Error {
        case sessionError(String)
        case invalidResponseType
        case httpError(Int, String)
        case decodingError(String)
        case unknownResponseDataFormat
        case apiError(Int, String)

        var description: String {
            switch self {
            case .sessionError(let message):
                return "sessionError: \(message)"
            case .invalidResponseType:
                return "invalidResponseType"
            case .httpError(let code, let message):
                return "httpError: \(code) \(message)"
            case .decodingError(let message):
                return "decodingError: \(message)"
            case .unknownResponseDataFormat:
                return "unknownResponseDataFormat"
            case .apiError(let code, let message):
                return "apiError: \(code) \(message)"
            }
        }
    }

    private func sendRequest<T>(_ request: URLRequest) async throws -> T where T: Decodable {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError {
            throw ResponseError.httpError(urlError.errorCode, urlError.localizedDescription)
        } catch {
            throw ResponseError.sessionError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidResponseType
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ResponseError.httpError(httpResponse.statusCode, httpResponse.description)
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw ResponseError.decodingError(error.localizedDescription)
        }
    }
}

struct JWT: Decodable {
    let header: Header
    let payload: Payload

    struct Header: Decodable {
        let algorithm: String
        let type: String

        enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case type = "typ"
        }
    }

    struct Payload: Decodable {
        let subject: String?
        let name: String?
        let issuedAt: Int?
        let issuer: String?
        let audience: String?
        let expiration: Date?
        let notBefore: Int?
        let jwtId: String?

        // Custom properties
        let userId: String?

        enum CodingKeys: String, CodingKey {
            case subject = "sub"
            case name = "name"
            case issuedAt = "iat"
            case issuer = "iss"
            case audience = "aud"
            case expiration = "exp"
            case notBefore = "nbf"
            case jwtId = "jti"
            case userId = "uid"
        }
    }

    static func decode(token: String) -> JWT? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            AppLog.v("Invalid JWT format")
            return nil
        }

        let headerSegment = String(segments[0])
        let payloadSegment = String(segments[1])

        guard let headerData = JWT.base64UrlDecode(headerSegment),
              let payloadData = JWT.base64UrlDecode(payloadSegment) else {
            AppLog.v("Base64Url decoding failed")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        guard let header = try? decoder.decode(JWT.Header.self, from: headerData),
              let payload = try? decoder.decode(JWT.Payload.self, from: payloadData) else {
            AppLog.v("JSON decoding failed")
            return nil
        }

        return JWT(header: header, payload: payload)
    }

    private static func base64UrlDecode(_ base64Url: String) -> Data? {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - base64.count % 4
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }

        return Data(base64Encoded: base64)
    }
}
