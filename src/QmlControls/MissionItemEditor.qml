import QtQuick                  2.2
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2

import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0


/// Mission item edit control
Rectangle {
    id: _root

    property var    missionItem ///< MissionItem associated with this editor
    property bool   readOnly    ///< true: read only view, false: full editing view

    signal clicked
    signal remove

    height: missionItem.isCurrentItem ?
                (missionItem.textFieldFacts.count * (measureTextField.height + _margin)) +
                    (missionItem.checkboxFacts.count * (measureCheckbox.height + _margin)) +
                    commandPicker.height + (deleteButton.visible ? deleteButton.height : 0) + (_margin * 9) :
                commandPicker.height + (_margin * 2)
    color:  missionItem.isCurrentItem ? qgcPal.buttonHighlight : qgcPal.windowShade

    readonly property real _editFieldWidth:     ScreenTools.defaultFontPixelWidth * 16
    readonly property real _margin:             ScreenTools.defaultFontPixelWidth / 3

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: enabled
    }

    QGCTextField {
        id:         measureTextField
        visible:    false
    }

    QGCCheckBox {
        id:         measureCheckbox
        visible:    false
    }

    Item {
        anchors.margins:    _margin
        anchors.fill:       parent

        MissionItemIndexLabel {
            id:                     label
            anchors.verticalCenter: commandPicker.verticalCenter
            isCurrentItem:          missionItem.isCurrentItem
            label:                  missionItem.sequenceNumber == 0 ? "H" : missionItem.sequenceNumber
        }

        MouseArea {
            anchors.fill:   parent
            visible:        !missionItem.isCurrentItem

            onClicked: _root.clicked()
        }

        QGCComboBox {
            id:                 commandPicker
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 10
            anchors.left:       label.right
            anchors.right:      parent.right
            currentIndex:       missionItem.commandByIndex
            model:              missionItem.commandNames
            visible:            missionItem.sequenceNumber != 0 // Item 0 is home position, can't change item type

            onActivated: missionItem.commandByIndex = index
        }

        Rectangle {
            anchors.fill:   commandPicker
            color:          qgcPal.button
            visible:        missionItem.sequenceNumber == 0 // Item 0 is home position, can't change item type

            QGCLabel {
                id:                 homeLabel
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                anchors.fill:       parent
                verticalAlignment:  Text.AlignVCenter
                text:               "Home"
                color:              qgcPal.buttonText
            }
        }

        Rectangle {
            anchors.topMargin:  _margin
            anchors.top:        commandPicker.bottom
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            anchors.right:      parent.right
            color:              qgcPal.windowShadeDark
            visible:            missionItem.isCurrentItem

            Item {
                anchors.margins:    _margin
                anchors.fill:   parent

                Column {
                    id:             valuesColumn
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    anchors.top:    parent.top
                    spacing:        _margin

                    Repeater {
                        model: missionItem.textFieldFacts

                        Item {
                            width:  valuesColumn.width
                            height: textField.height

                            QGCLabel {
                                id:                 textFieldLabel
                                anchors.baseline:   textField.baseline
                                text:               object.name
                            }

                            FactTextField {
                                id:             textField
                                anchors.right:  parent.right
                                width:          _editFieldWidth
                                showUnits:      true
                                fact:           object
                                visible:        !_root.readOnly
                            }

                            FactLabel {
                                anchors.baseline:   textFieldLabel.baseline
                                anchors.right:      parent.right
                                fact:               object
                                visible:            _root.readOnly
                            }
                        }
                    }

                    Item {
                        width:  10
                        height: missionItem.textFieldFacts.count ? _margin : 0
                    }

                    Repeater {
                        model: missionItem.checkboxFacts

                        FactCheckBox {
                            id:     textField
                            text:   object.name
                            fact:   object
                        }
                    }

                    Item {
                        width:  10
                        height: missionItem.checkboxFacts.count ? _margin : 0
                    }

                    Row {
                        width:      parent.width
                        spacing:    _margin

                        readonly property real buttonWidth: (width - (_margin * 2)) / 3

                        QGCButton {
                            id:         deleteButton
                            width:      parent.buttonWidth
                            text:       "Delete"
                            visible:    !readOnly

                            onClicked: _root.remove()
                        }
                    }

                } // Column
            } // Item
        } // Rectangle
    } // Item
} // Rectangle