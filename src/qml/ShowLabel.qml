import QtQuick 2.8
import IqC4Mobile 1.0
import "pallete.js" as Pallete

Item {
    property Show show
    property bool soon: {
        var diff = show.startDateTime.getTime() - currentDateTime.getTime()
        return diff > 0 && diff < 3600000
    }
    width: 115

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 5
        spacing: 0

        Rectangle {
            color: soon?Pallete.colorBlue:"transparent"
            width: 95
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter

            StyledText {
                id: time
                text: Qt.formatTime(show.startDateTime, "hh:mm")
                font.pixelSize: 33
                horizontalAlignment: Text.AlignHCenter
                color: show.startDateTime > currentDateTime?"white":"#6a6a6a"
                anchors.fill: parent
            }
        }


        StyledText {
            font.family: "PTRoubleSans"
            textFormat: Text.RichText
            text: {
                var result = '<font face="Museo Cyrl">'
                if (show.prices.length === 1) {
                    result += show.prices[0]
                } else {
                    result += "от " + show.prices.sort()[0]
                }
                result += "</font> 9"
            }
            font.pixelSize: 24
            color: show.startDateTime > currentDateTime?Pallete.colorPink:"transparent"
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
