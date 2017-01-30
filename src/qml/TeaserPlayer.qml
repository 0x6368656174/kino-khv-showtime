import QtQuick 2.7
import QtMultimedia 5.8
import IqC4Mobile 1.0
import QtQuick.Layouts 1.1
import "pallete.js" as Pallete

Item {
    Timer {
        interval: showtimeTime
        running: !teaserPlayer.visible && showtimeTime !== 0
        repeat: true
        onTriggered: {
            teaserPlayer.visible = true
        }
    }

    Timer {
        id: stopTimer
        interval: movieDialogTime
        onTriggered: onMovieEnd()
    }

    function onMovieEnd() {
        if (showtimeTime === 0) {
            mediaPlayer.playNext()
        } else {
            teaserPlayer.visible = false
        }
    }

    Connections {
        target: mediaPlayer

        onStateChanged: {
            if (mediaPlayer.state === MediaPlayer.StoppedState) {
                if (movie.valid) {
                    stopTimer.start()
                } else {
                    onMovieEnd()
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            mediaPlayer.playNext()
        }
    }

    Component.onCompleted: visibleChanged()

    Movie {
        id: movie
        objectId: mediaPlayer.movieId
    }

    NextShowModel {
        id: nextShow
        movieId: movie.objectId
        cinemaId: cinema.objectId
    }

    Image {
        visible: !video.visible && !movieInfo.visible
        source: "/src/images/logo.png"
        anchors.centerIn: parent
    }

    VideoOutput {
        id: video
        visible: mediaPlayer.state === MediaPlayer.PlayingState
        anchors.fill: parent
        source: mediaPlayer
    }

    function showDateFormat(show, shortFormat) {
        var currentDate = new Date()
        currentDate.setHours(0, 0, 0 ,0)
        var timeDiff = Math.abs(show.startDateTime.getTime() - currentDate.getTime());
        var diffDays = Math.floor(timeDiff / (1000 * 3600 * 24));
        var result = ""
        if (!shortFormat || diffDays > 2) {
            result += window.formatDate(show.startDateTime, "dd MMMM")
        }

        if (!shortFormat) {
            if (diffDays == 0) {
                result += ", сегодня"
            } else if (diffDays == 1) {
                result += ", завтра"
            } else if (diffDays == 2) {
                result += ", послезавтра"
            }
        } else {
            if (diffDays == 0) {
                result += "Сегодня"
            } else if (diffDays == 1) {
                result += "Завтра"
            } else if (diffDays == 2) {
                result += "Послезавтра"
            }
        }

        return result
    }

    Rectangle {
        visible: video.visible && movie.valid
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#272727"
        height: 135

        Border {
            width: parent.width
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 60
            anchors.rightMargin: 50
            anchors.topMargin: 4

            StyledText {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "white"
                font.pixelSize: 42
                font.weight: Font.DemiBold
                text: movie.title + ' <span style="color: #636363; font-weight: normal;">' + movie.ageLimit + "+</span>"
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            StyledText {
                visible: nextShow1Repeater.count == 0
                color: Pallete.colorPink
                font.pixelSize: 42
                wrapMode: Text.WordWrap
                Layout.leftMargin: 35
                text: "Премьера " + showDateFormat({startDateTime: movie.rentalStart}, false)
            }

            Repeater {
                id: nextShow1Repeater
                visible: count > 0
                model: nextShow
                delegate: RowLayout {
                    Show {
                        id: show2
                        objectId: model.objectId
                    }

                    CinemaHall {
                        id: cinemaHall2
                        objectId: show2.hallId
                    }

                    StyledText {
                        color: "#636363"
                        font.pixelSize: 42
                        wrapMode: Text.WordWrap
                        Layout.leftMargin: 35
                        text: showDateFormat(show2, false)
                    }

                    StyledText {
                        Layout.leftMargin: 35
                        color: "white"
                        font.pixelSize: 42
                        text: Qt.formatTime(show2.startDateTime, "hh:mm")
                    }

                    StyledText {
                        Layout.leftMargin: 35
                        color: Pallete.colorBlue
                        font.pixelSize: 42
                        text: cinemaHall2.name
                    }
                }
            }
        }
    }

    Rectangle {
        id: movieInfo
        visible: !video.visible && movie.valid
        width: 1620
        height: 490
        color: "#272727"
        anchors.centerIn: parent

        Border {
            width: parent.width
        }

        RowLayout {
            anchors.topMargin: 4
            anchors.fill: parent
            spacing: 0

            Image {
                id: movieImage
                Layout.fillHeight: true
                width: 486
                source: imageResizer.url

                ImageResizer {
                    id: imageResizer
                    image: movie.backdrop
                    filter: ImageResizer.Thumbnail
                    options: {
                        "method": "outbound",
                                "size": [movieImage.width, movieImage.height]
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: 120
                Layout.rightMargin: 120
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: movieImage.width
                spacing: 0

                StyledText {
                    color: "white"
                    font.pixelSize: 78
                    font.weight: Font.DemiBold
                    text: movie.title + ' <span style="color: #636363; font-weight: normal;">' + movie.ageLimit + "+</span>"
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.topMargin: 65
                }

                Item {
                    Layout.fillHeight: true
                }

                StyledText {
                    visible: nextShow2Repeater.count == 0
                    color: Pallete.colorPink
                    font.pixelSize: 53
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.bottomMargin: 75
                    verticalAlignment: Text.AlignBottom
                    text: "Премьера " + showDateFormat({startDateTime: movie.rentalStart}, false)
                }

                Repeater {
                    id: nextShow2Repeater
                    visible: count > 0
                    model: nextShow
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 75

                        Show {
                            id: show1
                            objectId: model.objectId
                        }

                        CinemaHall {
                            id: cinemaHall1
                            objectId: show1.hallId
                        }

                        StyledText {
                            color: "#636363"
                            font.pixelSize: 53
                            wrapMode: Text.WordWrap
                            Layout.alignment: Qt.AlignBottom
                            Layout.maximumWidth: 320
                            text: showDateFormat(show1, true)
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom
                            color: "white"
                            font.pixelSize: 68
                            text: Qt.formatTime(show1.startDateTime, "hh:mm")
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom
                            Layout.leftMargin: 35
                            color: Pallete.colorBlue
                            font.pixelSize: 68
                            text: cinemaHall1.name
                        }
                    }
                }
            }
        }
    }
}
