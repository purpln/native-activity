import NativeAppGlue

public enum InputEventTool: CInt {
    case unknown = 0 //AMOTION_EVENT_TOOL_TYPE_UNKNOWN
    case finger      //AMOTION_EVENT_TOOL_TYPE_FINGER
    case stylus      //AMOTION_EVENT_TOOL_TYPE_STYLUS
    case mouse       //AMOTION_EVENT_TOOL_TYPE_MOUSE
    case eraser      //AMOTION_EVENT_TOOL_TYPE_ERASER
    case palm        //AMOTION_EVENT_TOOL_TYPE_PALM
}
