public enum MotionEventAction: CInt {
    case down = 0      //AMOTION_EVENT_ACTION_DOWN
    case up            //AMOTION_EVENT_ACTION_UP
    case move          //AMOTION_EVENT_ACTION_MOVE
    case cancel        //AMOTION_EVENT_ACTION_CANCEL
    case outside       //AMOTION_EVENT_ACTION_OUTSIDE
    case pointerDown   //AMOTION_EVENT_ACTION_POINTER_DOWN
    case pointerUp     //AMOTION_EVENT_ACTION_POINTER_UP
    case hoverMove     //AMOTION_EVENT_ACTION_HOVER_MOVE
    case scroll        //AMOTION_EVENT_ACTION_SCROLL
    case hoverEnter    //AMOTION_EVENT_ACTION_HOVER_ENTER
    case hoverExit     //AMOTION_EVENT_ACTION_HOVER_EXIT
    case buttonPress   //AMOTION_EVENT_ACTION_BUTTON_PRESS
    case buttonRelease //AMOTION_EVENT_ACTION_BUTTON_RELEASE
}
