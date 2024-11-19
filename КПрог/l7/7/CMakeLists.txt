cmake_minimum_required(VERSION 3.16)

project(7 VERSION 0.1 LANGUAGES CXX ASM)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Core)

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
        windowsmanager.h
        windowsmanager.cpp
        openmanager.h
        openmanager.cpp
        openmanager.ui
        editwindow.h
        editwindow.cpp
        editwindow.ui
        savemanager.h
        savemanager.cpp
        savemanager.ui
        popups.h
        popups.cpp
        ciphermanager.h
        consts.h
        ciphermanager.cpp
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(7
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        cf.o
        tf.o
        rand.o
        vf.o
    )
else()
    if(ANDROID)
        add_library(7 SHARED
            ${PROJECT_SOURCES}
            cf.o
            vf.o
            tf.o
            rand.o
        )
    else()
        add_executable(7
            ${PROJECT_SOURCES}
            cf.o
            vf.o
            tf.o
            rand.o
        )
    endif()
endif()

target_link_libraries(7 PRIVATE Qt${QT_VERSION_MAJOR}::Widgets Qt${QT_VERSION_MAJOR}::Core)

if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.7)
endif()
set_target_properties(7 PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS 7
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(7)
endif()
