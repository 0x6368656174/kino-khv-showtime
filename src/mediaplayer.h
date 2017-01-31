#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAbstractVideoSurface>
#include <QFileSystemWatcher>
#include <QDateTime>
#include <QDir>
#include <QTimer>

class MediaPlayer : public QMediaPlayer
{
    Q_OBJECT
    Q_PROPERTY(QAbstractVideoSurface* videoSurface READ videoSurface WRITE setVideoSurface )
    Q_PROPERTY(int movieId READ movieId NOTIFY movieIdChanged)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)

public:
    explicit MediaPlayer(QObject *parent = nullptr);

    QAbstractVideoSurface *videoSurface() const;
    void setVideoSurface(QAbstractVideoSurface *videoSurface);

    int movieId() const;

    void setDir(const QString &dir);

    Q_INVOKABLE void playNext();

    bool enabled() const;

signals:
    void movieIdChanged();
    void enabledChanged();

private:
    QAbstractVideoSurface *m_videoSurface;
    QMediaPlaylist *m_playlist;
    QTimer *m_adsTimer;

    QFileSystemWatcher m_dirWatcher;
    QString m_dir;
    QStringList m_fileFilter;

    QStringList m_ads;
    int m_adsPeriod;
    QDateTime m_lastAdsShow;

    void updatePlaylist();

    void checkAds();
    void updateAds();
    QString getFilePath(const QString &file) const;
    int m_playlistIndex;
};

#endif // MEDIAPLAYER_H
