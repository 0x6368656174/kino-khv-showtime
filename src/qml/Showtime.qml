import QtQuick 2.7
import QtQuick.Window 2.2
import IqC4Mobile 1.0
import QtQuick.Layouts 1.1
import "pallete.js" as Pallete
import "cinemaConfig.js" as CinemaConfig

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        spacing: 0

        Item {
            height: 165
            Layout.fillWidth: true
            Image {
                source: CinemaConfig.config(cinemaName).logo
                anchors.bottom: parent.bottom
                anchors.bottomMargin: CinemaConfig.config(cinemaName).logoMargin
            }

            StyledText {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                font.pixelSize: 42
                font.weight: Font.DemiBold
                id: time
                text: setTime()
                color: Pallete.colorPink
                textFormat: Text.StyledText

                function setTime() {
                    var date = currentDateTime
                    var secColor = date.getMilliseconds() < 500?Pallete.colorPink:"transparent"
                    return '<font color="white">' + window.formatDate(date).toLowerCase() + "</font> " + Qt.formatTime(date, "hh")
                            + '<font color="' + secColor +'">' + ":</font>"
                            + Qt.formatTime(date, "mm")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: {
                var contentHeight = movies.contentHeight
                if (contentHeight < 0)
                    return 875
                return Math.min(875, contentHeight)
            }
            color: "#0f0f0f"
            clip: true

            ListView {
                id: movies
                anchors.fill: parent
                spacing: 10
                model: ShowMovieModel {
                    day: currentDateTime
                    cinemaId: cinema.objectId
                    hideGone: false
                }

                Timer {
                    interval: pageTime
                    running: true
                    repeat: true
                    onTriggered: {
                        var index = movies.indexAt(10, movies.contentY + movies.height)
                        positionAnimation.running = false
                        var pos = movies.contentY
                        var destPos
                        if (index > 0) {
                            movies.positionViewAtIndex(index, ListView.Beginning)
                            destPos = movies.contentY
                        } else {
                            destPos = 0
                        }
                        positionAnimation.from = pos
                        positionAnimation.to = destPos
                        positionAnimation.running = true
                    }
                }

                NumberAnimation {
                    id: positionAnimation
                    target: movies
                    property: "contentY"
                    duration: pageAnimationDuration
                    easing.type: Easing.InOutQuad
                }

                delegate: Item {
                    id: movieDelegate
                    height: 114 * cinemaHalls.count
                    width: movies.width

                    Border {
                        width: parent.width
                    }

                    Rectangle {
                        z: 1
                        property bool isTop: {
                            if (!positionAnimation.running && movies.indexAt(10, movies.contentY - 10) === index) {
                                return true
                            }
                            return false
                        }

                        visible: opacity !== 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: !isTop?parent.top:undefined
                        anchors.bottom: isTop?parent.bottom:undefined
                        rotation: isTop?180:0
                        height: {
                            if (!isTop)
                                return movies.contentY + movies.height - movieDelegate.y
                            return movieDelegate.y + movieDelegate.height - movies.contentY
                        }
                        opacity: {
                            var forConnect = movies.contentHeight
                            if (!positionAnimation.running && movies.indexAt(10, movies.contentY + movies.height) === index) {
                                return 0.6
                            }
                            if (!positionAnimation.running && movies.indexAt(10, movies.contentY - 10) === index) {
                                return 0.6
                            }

                            return 0
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.4; color: "black" }
                            GradientStop { position: 1.0; color: "black" }
                        }
                    }

                    Movie {
                        id: movie
                        objectId: model.objectId
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            width: 630
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 4
                            color: "#272727"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                MovieFormatLabel {
                                    movie: movie
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                StyledText {
                                    Layout.preferredWidth: 430
                                    wrapMode: Text.WordWrap
                                    text: movie.title
                                    color: "white"
                                    font.pixelSize: 33
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                StyledText {
                                    text: movie.ageLimit + "+"
                                    font.pixelSize: 32
                                    color: "#767676"
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.leftMargin: 20
                                    Layout.minimumWidth: 75
                                    Layout.maximumWidth: 75
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: parent.height
                            color: "#2d2d2d"

                            ListView {
                                id: cinemaHalls
                                anchors.fill: parent

                                model: ShowCinemaHallModel {
                                    day: currentDateTime
                                    cinemaId: cinema.objectId
                                    movieId: movie.objectId
                                    hideGone: false
                                }

                                delegate: Item {
                                    height: 114
                                    width: cinemaHalls.width

                                    Border {
                                        width: parent.width
                                    }

                                    RowLayout {
                                        spacing: 0
                                        anchors.fill: parent
                                        anchors.topMargin: 4

                                        Item {
                                            height: parent.height
                                            Layout.fillWidth: true
                                        }

                                        ListView {
                                            id: shows
                                            height: parent.height
                                            Layout.rightMargin: 30
                                            width: count * 115
                                            orientation: ListView.Horizontal
                                            spacing: 0

                                            model: ShowModel {
                                                cinemaId: cinema.objectId
                                                movieId: movie.objectId
                                                cinemaHallId: cinemaHall.objectId
                                                day: currentDateTime
                                                hideGoneShows: false
                                            }

                                            delegate: ShowLabel {
                                                height: shows.height
                                                show: Show {
                                                    objectId: model.objectId
                                                }
                                            }
                                        }

                                        Rectangle {
                                            color: "#272727"
                                            height: parent.height
                                            width: 220

                                            CinemaHall {
                                                id: cinemaHall
                                                objectId: model.objectId
                                            }

                                            StyledText {
                                                text: cinemaHall.name
                                                font.pixelSize: 30
                                                font.weight: Font.DemiBold
                                                color: Pallete.colorBlue
                                                anchors.fill: parent
                                                anchors.leftMargin: 18
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
