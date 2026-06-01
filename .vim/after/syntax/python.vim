syn keyword pythonROSLib rospkg actionlib tf tf2
syn match   pythonROSLib /\<rospy\>/
syn keyword pythonROSType std_msgs sensor_msgs geometry_msgs nav_msgs visualization_msgs
syn match   pythonROSType /\<tf2_ros\>/
syn match   pythonROSFunction /\<rospy\.\w\+\>/
syn match   pythonROSFunction /\<tf2_ros\.\w\+\>/

hi def link pythonROSLib     Include
hi def link pythonROSType    Type
hi def link pythonROSFunction Function