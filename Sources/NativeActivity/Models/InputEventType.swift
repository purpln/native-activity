public enum InputEventType: CInt {
    case key = 1   //AINPUT_EVENT_TYPE_KEY
    case motion    //AINPUT_EVENT_TYPE_MOTION
    case focus     //AINPUT_EVENT_TYPE_FOCUS
    case capture   //AINPUT_EVENT_TYPE_CAPTURE
    case drag      //AINPUT_EVENT_TYPE_DRAG
    case touchMode //AINPUT_EVENT_TYPE_TOUCH_MODE
}
