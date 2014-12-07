HTKUltimateParentalGate
=======================

The Ultimate Parental Gate to help block children from accessing in app purchases within an app. Most "Parental Gates" simply ask a math question or provide a question that a child can figure out by randomly selecting an item on the screen. This is unique in it requires both math and dexterity skills to succeed, which typically a child does not have at a young age. 

The way it works is a view is presented to the user, which asks a simple math question in sentence form. The possible answers are displayed inside a number of balls that move around the screen at a random rate. The user has to then tap the answer and drag it to a small square in the corner of the view before time runs out. If the user selects the wrong answer too many times, it will exit the gate. If the user makes too many overall attempts in a row, it will lock the user out of the app for a few minutes (all of these values are customizable). Thus, making this the "Ultimate" Parental Gate.

This is the same Parental Gate used in the popular special needs app, SpeechBox for iPad (http://www.speechboxapp.com). Therefore, this has been tested for over a year in both home and clinical environments, and have yet had a child get past the gate. This doesn't mean it's perfect, but it provides more security than other solutions.

If anyone can help localizing this, please create and issue or pull request.

## Adding to your project:
### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add HTKDragAndDropCollectionViewLayout to your project.

1. Add a pod entry for HTKUltimateParentalGate to your Podfile `pod 'HTKUltimateParentalGate', '~> 0.0.1'`
2. Install the pod(s) by running `pod install`.
3. Import `HTKParentalGateViewController.h` where you will use it.
4. Register for the `HTKParentalGateValidationStateChangedNotification` notification in the class you want to receive state changes to. You'll receive notifications such as when the user failed or passed successfully.
5. The notification returns the `HTKParentalGateValidationState` value in the userInfo dictionary in the `HTKParentalGateValidationStateChangedKey` key, which is the  validation state of the gate.
6. The gate automatically dismisses on failed/success attempts and displays and alertView on failed attempt to the user. You can customize the messages in the constants file. At a minimum you just need to present the next view on success.
7. If you would like to add/modify the questions, they are located in the `HTKParentalGateQuestions.plist`.

## Sample video:

[![YouTube Sample Video](http://img.youtube.com/vi/S8rUR_iQRPY/0.jpg)](http://www.youtube.com/watch?v=S8rUR_iQRPY)

## Screen shot:

![Sample Screenshot](http://htk-github.s3.amazonaws.com/HTKUltimateParentalGateSS1.png)

## Change log:
v0.0.1: Initial project commit

Questions? Email: henrytkirk@gmail.com or Web: http://www.henrytkirk.info
