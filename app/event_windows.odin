package app

import win32 "core:sys/windows"

Event_Size_Type :: enum {
    Restored = win32.SIZE_RESTORED,
    Minimized = win32.SIZE_MINIMIZED,
    Max_Show = win32.SIZE_MAXSHOW,
    Maximized = win32.SIZE_MAXIMIZED,
    Max_Hide = win32.SIZE_MAXHIDE,
}

Event_Activate_Type :: enum {
    Inactive = win32.WA_INACTIVE,
    Active = win32.WA_ACTIVE,
    Click_Active = win32.WA_CLICKACTIVE,
}