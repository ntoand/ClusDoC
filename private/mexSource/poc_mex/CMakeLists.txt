cmake_minimum_required(VERSION 2.8)
project(poc)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c++0x")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

if(DEBUG)
  message("Debug is on")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -ggdb3")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -ggdb3")
endif(DEBUG)

find_package(OpenMP REQUIRED)
if(OPENMP_FOUND)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")

  # Main app
  SET( srcs 
      utils.cpp
      kdtree2.cpp
      main.cpp 
      )

  # Headers
  SET( headers
      utils.h
      kdtree2.hpp
      )

  set(ALL_LIBS
    
  )

  add_executable(poc ${srcs} ${headers})

  # create the program
  target_link_libraries(poc ${ALL_LIBS} )


else(OPENMP_FOUND)
  message("ERROR: OpenMP could not be found.")
endif(OPENMP_FOUND)