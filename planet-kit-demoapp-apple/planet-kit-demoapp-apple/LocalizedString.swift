import Foundation

enum LocalizedString {

    /// "Incoming video call.."
    case lp_demoapp_1to1_noti_video

    /// "Incoming audio call.."
    case lp_demoapp_1to1_noti_voice

    /// "Basic Call"
    case lp_demoapp_1to1_scenarios_basic

    /// "Calling..."
    case lp_demoapp_1to1_scenarios_basic_calling

    /// "End call"
    case lp_demoapp_1to1_scenarios_basic_endcall1

    /// "The call has ended."
    case lp_demoapp_1to1_scenarios_basic_endcall2

    /// "OK"
    case lp_demoapp_1to1_scenarios_basic_endcall3

    /// "Peer\\'s microphone is off."
    case lp_demoapp_1to1_scenarios_basic_inacall1

    /// "Peer\\'s camera is off."
    case lp_demoapp_1to1_scenarios_basic_inacall2

    /// "Audio Call"
    case lp_demoapp_1to1_scenarios_basic_setup_btn1

    /// "Video Call"
    case lp_demoapp_1to1_scenarios_basic_setup_btn2

    /// "Peer id (callee)"
    case lp_demoapp_1to1_scenarios_basic_setup_callee

    /// "Enter your opponent\\'s User ID.\nOnly English letters, hyphens (-), underscores (_), and numbers are allowed for input, with a maximum limit of 64 characters."
    case lp_demoapp_1to1_scenarios_basic_setup_guide

    /// "Input Peer id (User id)"
    case lp_demoapp_1to1_scenarios_basic_setup_placeholder

    /// "Dating"
    case lp_demoapp_1to1_scenarios_dating

    /// "Expert consultation"
    case lp_demoapp_1to1_scenarios_expert

    /// "We will continue to update the call view suitable for the scenario."
    case lp_demoapp_1to1_scenarios_guide

    /// "Mobility / Delivery"
    case lp_demoapp_1to1_scenarios_mobility

    /// "1:1 Call"
    case lp_demoapp_1to1_scenarios_title

    /// "The format of Peer Id(User Id) is incorrect."
    case lp_demoapp_1to1_setup_incorrectid

    /// "Switched to the {{mic name}} microphone."
    case lp_demoapp_common_changemic(String)

    /// "An error occurred."
    case lp_demoapp_common_default_error_msg

    /// "Start Fail"
    case lp_demoapp_common_error_startfail0

    /// "Peer id is not found, please input a peer id and try again."
    case lp_demoapp_common_error_startfail1

    /// "Room name is not found, please enter a room name and try again."
    case lp_demoapp_common_error_startfail2

    /// "Insufficient permissions for the call. Please grant the app microphone permission and try again."
    case lp_demoapp_common_error_startfail3

    /// "Failed to mute. Please try again."
    case lp_demoapp_common_fail_mute

    /// "Microphone"
    case lp_demoapp_common_mic

    /// "LINE Planet Call would like to access your camera to provide video call functionality."
    case lp_demoapp_common_permission_camera

    /// "LINE Planet Call requires access to your microphone for call functionality."
    case lp_demoapp_common_permission_mic

    /// "Allow ‘LINE Planet Call’ to access your microphone under ‘LINE Planet Call’ in your device’s settings."
    case lp_demoapp_common_permission_noti1

    /// "Allow ‘LINE Planet Call’ to access your camera under ‘LINE Planet Call’ in your device’s settings."
    case lp_demoapp_common_permission_noti2

    /// "Allow ‘LINE Planet Call’ to access your camera and microphone under ‘LINE Planet Call’ in your device’s settings."
    case lp_demoapp_common_permission_noti3

    /// "Speaker"
    case lp_demoapp_common_speaker

    /// "Use system settings"
    case lp_demoapp_common_systemsetting

    /// "Basic Call"
    case lp_demoapp_group_scenarios_basic

    /// "Leave"
    case lp_demoapp_group_scenarios_basic_inacall_btn

    /// "{{User name}} has left the group call."
    case lp_demoapp_group_scenarios_basic_inacall_toast(String)

    /// "Game / Metaverse"
    case lp_demoapp_group_scenarios_game

    /// "We will continue to update the call view suitable for the scenario."
    case lp_demoapp_group_scenarios_guide

    /// "Online education"
    case lp_demoapp_group_scenarios_onlineedu

    /// "Enter Room"
    case lp_demoapp_group_scenarios_preview_btn

    /// "Camera preview"
    case lp_demoapp_group_scenarios_preview_title

    /// "Remote work"
    case lp_demoapp_group_scenarios_remotework

    /// "Enter preview"
    case lp_demoapp_group_scenarios_setup_btn

    /// "Room name"
    case lp_demoapp_group_scenarios_setup_roomname

    /// "Room Id is allowed up to 20 characters."
    case lp_demoapp_group_scenarios_setup_roomnameguide

    /// "Social / Community"
    case lp_demoapp_group_scenarios_social

    /// "Group Call"
    case lp_demoapp_group_scenarios_title

    /// "1:1 Call"
    case lp_demoapp_main_btn1

    /// "Group Call"
    case lp_demoapp_main_btn2

    /// "The service is available after you complete the core setup from the gear icon in the upper right corner."
    case lp_demoapp_main_guide

    /// "Demo App {{major.minor.patch}}"
    case lp_demoapp_main_versioninfo1(String)

    /// "SDK {{major.minor.patch}}"
    case lp_demoapp_main_versioninfo2(String)

    /// "Save"
    case lp_demoapp_setting_btn1

    /// "RESET NOW"
    case lp_demoapp_setting_btn2

    /// "My name, My user id are required. Please enter them and try again."
    case lp_demoapp_setting_error_savefail

    /// "The format of My User Id is incorrect."
    case lp_demoapp_setting_error_savefail1

    /// "This item is for identifying users and facilitating communication in a multi-participant conversation. My name is allowed up to 10 characters."
    case lp_demoapp_setting_guide1

    /// "This is the information that uniquely identifies you in Call and is automatically reset after 60 minutes and can be saved again if reset.\nOnly English letters, hyphens (-), underscores (_), and numbers are allowed for input, with a maximum limit of 64 characters."
    case lp_demoapp_setting_guide2

    /// "Enter the Service Id issued to you in the Planet Console."
    case lp_demoapp_setting_guide3

    /// "Force reset time: {{YYYY-MM-DD hh.mm.ss}} {{gmt info}}"
    case lp_demoapp_setting_guide4(String, String)

    /// "My user id"
    case lp_demoapp_setting_myuserid

    /// "My name"
    case lp_demoapp_setting_name

    /// "Set your name"
    case lp_demoapp_setting_placeholder1

    /// "Set your user id"
    case lp_demoapp_setting_placeholder2

    /// "Verify your service id"
    case lp_demoapp_setting_placeholder3

    /// "Failed to save."
    case lp_demoapp_setting_popup1

    /// "The registered User ID already exists. Please register a different User ID."
    case lp_demoapp_setting_popup2

    /// "OK"
    case lp_demoapp_setting_popup3

    /// "Cancel"
    case lp_demoapp_setting_popup4

    /// "Initialize the Setting information."
    case lp_demoapp_setting_popup5

    /// "Initialization of setting is deleted information from the authenticated service ID."
    case lp_demoapp_setting_popup6

    /// "Both Name and User id are initialized."
    case lp_demoapp_setting_popup7

    /// "Service id"
    case lp_demoapp_setting_serviceid

    /// "Setting"
    case lp_demoapp_setting_title

    var string: String {
        switch self {
        case .lp_demoapp_1to1_noti_video:
            return NSLocalizedString("lp_demoapp_1to1_noti_video", comment: "")

        case .lp_demoapp_1to1_noti_voice:
            return NSLocalizedString("lp_demoapp_1to1_noti_voice", comment: "")

        case .lp_demoapp_1to1_scenarios_basic:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_calling:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_calling", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_endcall1:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_endcall1", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_endcall2:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_endcall2", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_endcall3:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_endcall3", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_inacall1:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_inacall1", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_inacall2:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_inacall2", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_setup_btn1:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_setup_btn1", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_setup_btn2:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_setup_btn2", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_setup_callee:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_setup_callee", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_setup_guide:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_setup_guide", comment: "")

        case .lp_demoapp_1to1_scenarios_basic_setup_placeholder:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_basic_setup_placeholder", comment: "")

        case .lp_demoapp_1to1_scenarios_dating:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_dating", comment: "")

        case .lp_demoapp_1to1_scenarios_expert:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_expert", comment: "")

        case .lp_demoapp_1to1_scenarios_guide:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_guide", comment: "")

        case .lp_demoapp_1to1_scenarios_mobility:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_mobility", comment: "")

        case .lp_demoapp_1to1_scenarios_title:
            return NSLocalizedString("lp_demoapp_1to1_scenarios_title", comment: "")

        case .lp_demoapp_1to1_setup_incorrectid:
            return NSLocalizedString("lp_demoapp_1to1_setup_incorrectid", comment: "")

        case .lp_demoapp_common_changemic(let param0):
            let format = NSLocalizedString("lp_demoapp_common_changemic", comment: "")
            let replaced0 = format.replacingOccurrences(of: "{{mic name}}", with: param0)
            return replaced0

        case .lp_demoapp_common_default_error_msg:
            return NSLocalizedString("lp_demoapp_common_default_error_msg", comment: "")

        case .lp_demoapp_common_error_startfail0:
            return NSLocalizedString("lp_demoapp_common_error_startfail0", comment: "")

        case .lp_demoapp_common_error_startfail1:
            return NSLocalizedString("lp_demoapp_common_error_startfail1", comment: "")

        case .lp_demoapp_common_error_startfail2:
            return NSLocalizedString("lp_demoapp_common_error_startfail2", comment: "")

        case .lp_demoapp_common_error_startfail3:
            return NSLocalizedString("lp_demoapp_common_error_startfail3", comment: "")

        case .lp_demoapp_common_fail_mute:
            return NSLocalizedString("lp_demoapp_common_fail_mute", comment: "")

        case .lp_demoapp_common_mic:
            return NSLocalizedString("lp_demoapp_common_mic", comment: "")

        case .lp_demoapp_common_permission_camera:
            return NSLocalizedString("lp_demoapp_common_permission_camera", comment: "")

        case .lp_demoapp_common_permission_mic:
            return NSLocalizedString("lp_demoapp_common_permission_mic", comment: "")

        case .lp_demoapp_common_permission_noti1:
            return NSLocalizedString("lp_demoapp_common_permission_noti1", comment: "")

        case .lp_demoapp_common_permission_noti2:
            return NSLocalizedString("lp_demoapp_common_permission_noti2", comment: "")

        case .lp_demoapp_common_permission_noti3:
            return NSLocalizedString("lp_demoapp_common_permission_noti3", comment: "")

        case .lp_demoapp_common_speaker:
            return NSLocalizedString("lp_demoapp_common_speaker", comment: "")

        case .lp_demoapp_common_systemsetting:
            return NSLocalizedString("lp_demoapp_common_systemsetting", comment: "")

        case .lp_demoapp_group_scenarios_basic:
            return NSLocalizedString("lp_demoapp_group_scenarios_basic", comment: "")

        case .lp_demoapp_group_scenarios_basic_inacall_btn:
            return NSLocalizedString("lp_demoapp_group_scenarios_basic_inacall_btn", comment: "")

        case .lp_demoapp_group_scenarios_basic_inacall_toast(let param0):
            let format = NSLocalizedString("lp_demoapp_group_scenarios_basic_inacall_toast", comment: "")
            let replaced0 = format.replacingOccurrences(of: "{{User name}}", with: param0)
            return replaced0

        case .lp_demoapp_group_scenarios_game:
            return NSLocalizedString("lp_demoapp_group_scenarios_game", comment: "")

        case .lp_demoapp_group_scenarios_guide:
            return NSLocalizedString("lp_demoapp_group_scenarios_guide", comment: "")

        case .lp_demoapp_group_scenarios_onlineedu:
            return NSLocalizedString("lp_demoapp_group_scenarios_onlineedu", comment: "")

        case .lp_demoapp_group_scenarios_preview_btn:
            return NSLocalizedString("lp_demoapp_group_scenarios_preview_btn", comment: "")

        case .lp_demoapp_group_scenarios_preview_title:
            return NSLocalizedString("lp_demoapp_group_scenarios_preview_title", comment: "")

        case .lp_demoapp_group_scenarios_remotework:
            return NSLocalizedString("lp_demoapp_group_scenarios_remotework", comment: "")

        case .lp_demoapp_group_scenarios_setup_btn:
            return NSLocalizedString("lp_demoapp_group_scenarios_setup_btn", comment: "")

        case .lp_demoapp_group_scenarios_setup_roomname:
            return NSLocalizedString("lp_demoapp_group_scenarios_setup_roomname", comment: "")

        case .lp_demoapp_group_scenarios_setup_roomnameguide:
            return NSLocalizedString("lp_demoapp_group_scenarios_setup_roomnameguide", comment: "")

        case .lp_demoapp_group_scenarios_social:
            return NSLocalizedString("lp_demoapp_group_scenarios_social", comment: "")

        case .lp_demoapp_group_scenarios_title:
            return NSLocalizedString("lp_demoapp_group_scenarios_title", comment: "")

        case .lp_demoapp_main_btn1:
            return NSLocalizedString("lp_demoapp_main_btn1", comment: "")

        case .lp_demoapp_main_btn2:
            return NSLocalizedString("lp_demoapp_main_btn2", comment: "")

        case .lp_demoapp_main_guide:
            return NSLocalizedString("lp_demoapp_main_guide", comment: "")

        case .lp_demoapp_main_versioninfo1(let param0):
            let format = NSLocalizedString("lp_demoapp_main_versioninfo1", comment: "")
            let replaced0 = format.replacingOccurrences(of: "{{major.minor.patch}}", with: param0)
            return replaced0

        case .lp_demoapp_main_versioninfo2(let param0):
            let format = NSLocalizedString("lp_demoapp_main_versioninfo2", comment: "")
            let replaced0 = format.replacingOccurrences(of: "{{major.minor.patch}}", with: param0)
            return replaced0

        case .lp_demoapp_setting_btn1:
            return NSLocalizedString("lp_demoapp_setting_btn1", comment: "")

        case .lp_demoapp_setting_btn2:
            return NSLocalizedString("lp_demoapp_setting_btn2", comment: "")

        case .lp_demoapp_setting_error_savefail:
            return NSLocalizedString("lp_demoapp_setting_error_savefail", comment: "")

        case .lp_demoapp_setting_error_savefail1:
            return NSLocalizedString("lp_demoapp_setting_error_savefail1", comment: "")

        case .lp_demoapp_setting_guide1:
            return NSLocalizedString("lp_demoapp_setting_guide1", comment: "")

        case .lp_demoapp_setting_guide2:
            return NSLocalizedString("lp_demoapp_setting_guide2", comment: "")

        case .lp_demoapp_setting_guide3:
            return NSLocalizedString("lp_demoapp_setting_guide3", comment: "")

        case .lp_demoapp_setting_guide4(let param0, let param1):
            let format = NSLocalizedString("lp_demoapp_setting_guide4", comment: "")
            let replaced0 = format.replacingOccurrences(of: "{{YYYY-MM-DD hh.mm.ss}}", with: param0)
            let replaced1 = replaced0.replacingOccurrences(of: "{{gmt info}}", with: param1)
            return replaced1

        case .lp_demoapp_setting_myuserid:
            return NSLocalizedString("lp_demoapp_setting_myuserid", comment: "")

        case .lp_demoapp_setting_name:
            return NSLocalizedString("lp_demoapp_setting_name", comment: "")

        case .lp_demoapp_setting_placeholder1:
            return NSLocalizedString("lp_demoapp_setting_placeholder1", comment: "")

        case .lp_demoapp_setting_placeholder2:
            return NSLocalizedString("lp_demoapp_setting_placeholder2", comment: "")

        case .lp_demoapp_setting_placeholder3:
            return NSLocalizedString("lp_demoapp_setting_placeholder3", comment: "")

        case .lp_demoapp_setting_popup1:
            return NSLocalizedString("lp_demoapp_setting_popup1", comment: "")

        case .lp_demoapp_setting_popup2:
            return NSLocalizedString("lp_demoapp_setting_popup2", comment: "")

        case .lp_demoapp_setting_popup3:
            return NSLocalizedString("lp_demoapp_setting_popup3", comment: "")

        case .lp_demoapp_setting_popup4:
            return NSLocalizedString("lp_demoapp_setting_popup4", comment: "")

        case .lp_demoapp_setting_popup5:
            return NSLocalizedString("lp_demoapp_setting_popup5", comment: "")

        case .lp_demoapp_setting_popup6:
            return NSLocalizedString("lp_demoapp_setting_popup6", comment: "")

        case .lp_demoapp_setting_popup7:
            return NSLocalizedString("lp_demoapp_setting_popup7", comment: "")

        case .lp_demoapp_setting_serviceid:
            return NSLocalizedString("lp_demoapp_setting_serviceid", comment: "")

        case .lp_demoapp_setting_title:
            return NSLocalizedString("lp_demoapp_setting_title", comment: "")
        }
    }
}
