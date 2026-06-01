syn match cppROSNamespace /ros\w*::/
syn keyword cppROSHeader ros ros_msgs std_msgs sensor_msgs geometry_msgs nav_msgs
syn match cppROSType /[A-Z]\w*_msgs\|tf2\|tf/
syn match cppROSFunction /\<ros::\w\+\>/
syn match cppROSFunction /\<tf2::\w\+\>/

hi def link cppROSNamespace  Structure
hi def link cppROSHeader     PreProc
hi def link cppROSType       Type
hi def link cppROSFunction   Function
