import QtQuick 2.0
import IqC4Mobile 1.0
import "pallete.js" as Pallete;

Item {
    property Movie movie

    width: 100 * sc
    height: 40 * sc

    Item {
        width: movie.has2DFormat && movie.has3DFormat?70:40
        height: 40 * sc
        anchors.centerIn: parent

        Rectangle {
            color: Pallete.colorPink
            width: 40 * sc
            height: 40 * sc
            radius: 40 * sc
            visible: movie.has3DFormat

            StyledSansText {
                anchors.fill: parent
                text: "3D"
                font.weight: Font.Black
                font.pixelSize: 23 * sc
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: "white"
            }
        }

        Rectangle {
            color: Pallete.colorBlue
            width: 40 * sc
            height: 40 * sc
            radius: 40 * sc
            visible: movie.has2DFormat
            x: movie.has3DFormat?30 * sc:0

            StyledSansText {
                anchors.fill: parent
                text: "2D"
                font.weight: Font.Black
                font.pixelSize: 23 * sc
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: "white"
            }
        }
    }
}
