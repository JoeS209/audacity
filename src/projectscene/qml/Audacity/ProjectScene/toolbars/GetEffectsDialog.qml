import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Muse.Ui
import Muse.UiComponents

import Audacity.ProjectScene

StyledDialogView {
    id: root

    title: qsTrc("projectscene", "Get Effects")

    contentWidth: 920
    contentHeight: 650

    modal: true
    resizable: false

    GetEffectsModel {
        id: effectsModel
    }

    Component.onCompleted: {
        effectsModel.load()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Category tabs
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: ui.theme.backgroundSecondaryColor

            RowLayout {
                id: categoryRow
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 4

                Repeater {
                    model: effectsModel.categories

                    FlatButton {
                        text: modelData
                        accentButton: index === effectsModel.selectedCategoryIndex
                        onClicked: effectsModel.selectedCategoryIndex = index
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        SeparatorLine {}

        // Main content
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Loading
            ColumnLayout {
                anchors.centerIn: parent
                visible: effectsModel.isLoading
                spacing: 12

                StyledBusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: effectsModel.isLoading
                }

                StyledTextLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTrc("projectscene", "Please wait...")
                    font: ui.theme.largeBodyFont
                }
            }

            // Error
            ColumnLayout {
                anchors.centerIn: parent
                visible: effectsModel.hasError && !effectsModel.isLoading
                spacing: 16

                StyledTextLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTrc("projectscene", "Connection error")
                    font: ui.theme.largeBodyBoldFont
                }

                StyledTextLabel {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 400
                    text: qsTrc("projectscene", "Audacity is unable to connect to MuseHub.com. Please check your connection and try again.")
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                FlatButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTrc("projectscene", "Try again")
                    onClicked: effectsModel.load()
                }
            }

            // Effects grid
            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                visible: !effectsModel.isLoading && !effectsModel.hasError
                contentHeight: effectsColumn.height
                clip: true

                ScrollBar.vertical: StyledScrollBar {}

                Column {
                    id: effectsColumn
                    width: parent.width
                    spacing: 24

                    Repeater {
                        model: effectsModel.effectsGroups

                        delegate: effectsGroupDelegate
                    }
                }
            }
        }

        SeparatorLine {}

        // Bottom bar
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 12

            FlatButton {
                text: qsTrc("projectscene", "Become a Partner")
                onClicked: effectsModel.openBecomeAPartnerUrl()
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonBox {
                buttons: [ButtonBoxModel.Done]
                navigationPanel.section: root.navigationSection
                navigationPanel.order: 1
                onStandardButtonClicked: function (buttonId) {
                    if (buttonId === ButtonBoxModel.Done)
                        root.accept()
                }
            }
        }
    }

    Component {
        id: effectsGroupDelegate

        Column {
            width: effectsColumn.width
            spacing: 12

            required property var modelData

            StyledTextLabel {
                text: modelData.title
                font: ui.theme.largeBodyBoldFont
                horizontalAlignment: Text.AlignLeft
            }

            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 40
                rowSpacing: 16

                Repeater {
                    model: modelData.effects

                    RowLayout {
                        Layout.preferredWidth: (effectsColumn.width - 40) / 2
                        Layout.preferredHeight: 118
                        spacing: 16

                        required property var modelData

                        Rectangle {
                            Layout.preferredWidth: 118
                            Layout.preferredHeight: 118
                            radius: 12
                            color: ui.theme.buttonColor
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: modelData.iconUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            StyledTextLabel {
                                Layout.fillWidth: true
                                text: modelData.title
                                font: ui.theme.bodyBoldFont
                                horizontalAlignment: Text.AlignLeft
                                maximumLineCount: 1
                                elide: Text.ElideRight
                            }

                            StyledTextLabel {
                                Layout.fillWidth: true
                                text: modelData.subtitle
                                horizontalAlignment: Text.AlignLeft
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            FlatButton {
                                text: qsTrc("projectscene", "Get it on MuseHub")
                                accentButton: true
                                onClicked: effectsModel.openEffectUrl(modelData.code)
                            }
                        }
                    }
                }
            }
        }
    }
}
