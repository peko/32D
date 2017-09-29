# Do the linking for executables that are meant to link raylib
function(link_with_raylib executable)
  # Link the libraries
  target_link_libraries(${executable} m pthread dl)
  target_link_libraries(${executable} openal)
  target_link_libraries(${executable} GL)
  target_link_libraries(${executable} X11 Xrandr Xinerama Xi Xxf86vm Xcursor)  # X11 stuff
  
  # Add in GLFW as a linking target
  target_link_libraries(${executable} glfw)

  # And raylib
  target_link_libraries(${executable} raylib)
endfunction()
