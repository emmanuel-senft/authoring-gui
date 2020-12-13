Task-Level Authoring for Robot Teleoperation
============================================
Authoring GUI
-------------



*This work is part of the code for the implementation of the system presented in  Task-Level Authoring for Robot Teleoperation. It is designed to be used with the
[Robot Controller](https://github.com/emmanuel-senft/authoring-ros/tree/study).*

![Screenshot of the interface](docs/gui.png)


Pre-requisites
--------------

The Authoring GUI depends on one QtQuick extensions:

- [ROS plugin for QtQuick](https://github.com/emmanuel-senft/ros-qml-plugin)
(adapted from Séverin Lemaignan's)

Install and compile before running the interface.

Installation
------------

Simply open the Qt project from QtCreator and run it from there.

Usage
-----

See [the Robot Controller repository](https://github.com/emmanuel-senft/authoring-ros/tree/study) for detailed usage.

Interface
---------

This interface is designed to author short term program for robot remotely. It communicates with the robot controller using the QML-ROS plugin to receive ROS messages (video and strings) and send commands as strings.

The main view presents the field from a robot mounted camera with a number of buttons surrounding it. An overlays on the video shows the position of objects known by the system and with which users can interact. The bottom buttons allow to move the camera in the 6 directions. To create plans for the robot, the user can click or press and drag on the interface to create action areas. The interface will select an object in the area and select the default action associated. Users can change objects by click on the right radio buttons and can change actions by using the left checkbox. Actions order can be changed by deselcting and reselecting options or using the small arrows on the right. Actions or series of actions are applied to each object of the same type in the area to simplify execution on multiple object. Moving actions offer interactive handles that can be moved by the user, for example to move known objects (e.g., screws) users can drag the anchor on the object to the destination area. For unknown objects, the interface provides a 3-points handle that shows a vertical grasp (with orientation) for both the pick and the place actions.

Users can specify multiple actions at once and the resulting plan is displayed on the right side of the interface. Users can then run the plans by pressing the 'play' button.