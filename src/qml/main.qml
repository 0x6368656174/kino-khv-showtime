import QtQuick 2.7
import QtQuick.Window 2.2
import IqC4Mobile 1.0
import QtQuick.Layouts 1.1
import "pallete.js" as Pallete
import "cinemaConfig.js" as CinemaConfig

Window {
    id: window
    visible: true
    visibility: fullSceen?Window.FullScreen:Window.Windowed
    width: 1920
    height: 1080
    title: qsTr("Hello World")

    Component.onCompleted: update()

    property var currentDateTime: new Date()

    function formatDate(date) {
        var str = Qt.formatDate(date, "dd")

        switch(date.getMonth()) {
        case (0): str += " января"; break;
        case (1): str += " февраля"; break;
        case (2): str += " марта"; break;
        case (3): str += " апреля"; break;
        case (4): str += " мая"; break;
        case (5): str += " июня"; break;
        case (6): str += " июля"; break;
        case (7): str += " августа"; break;
        case (8): str += " сентября"; break;
        case (9): str += " октября"; break;
        case (10): str += " ноября"; break;
        case (11): str += " декабря"; break;
        }

        return str
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: currentDateTime = new Date()
    }

    Rectangle {
        anchors.fill: parent
        color: "#171717"
    }

    Image {
        anchors.fill: parent
        source: "/src/images/pattern.png"
        fillMode: Image.Tile
    }

    Cinema {
        id: cinema
        objectId: CinemaConfig.config(cinemaName).id
    }

    TeaserPlayer {
        visible: showtimeTime === 0
        id: teaserPlayer
        anchors.fill: parent
    }

    Showtime {
        visible: !teaserPlayer.visible
        id: showtime
        anchors.fill: parent
    }
}
