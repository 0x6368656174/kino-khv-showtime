#include "mediaplayer.h"
#include <QMediaPlaylist>
#include <QDebug>

MediaPlayer::MediaPlayer(QObject *parent) :
    QMediaPlayer(parent),
    m_playlist(new QMediaPlaylist(this)),
    m_adsTimer(new QTimer(this)),
    m_playlistIndex(-1)
{
    m_playlist->setPlaybackMode(QMediaPlaylist::CurrentItemOnce);
    setPlaylist(m_playlist);

    m_fileFilter << "*.avi" << "*.mp4" << "*.mkv" << "*.mpg" << "*.flv" << "*.mod" << "*.h264" << "*.mpeg";

    m_adsTimer->setInterval(1000);
    m_adsTimer->setSingleShot(false);
    connect(m_adsTimer, &QTimer::timeout, this, &MediaPlayer::checkAds);
    m_adsTimer->start();

    connect(&m_dirWatcher, &QFileSystemWatcher::directoryChanged, this, [this](){
        m_playlist->clear();
        m_ads.clear();
        updatePlaylist();
        updateAds();
    });
}

QAbstractVideoSurface *MediaPlayer::videoSurface() const
{
    return m_videoSurface;
}

void MediaPlayer::setVideoSurface(QAbstractVideoSurface *videoSurface)
{
    m_videoSurface = videoSurface;
    setVideoOutput(videoSurface);
}

int MediaPlayer::movieId() const
{
    auto currentMediaFilePath = m_playlist->media(m_playlistIndex).canonicalUrl().toString();

    QStringList fileParts = currentMediaFilePath.split('/');
    auto file = fileParts.last();

    QRegExp rx (R"(kino-khv-(\d+))");
    if (rx.indexIn(file) != -1)
        return rx.cap(1).toInt();

    return -1;
}

void MediaPlayer::setDir(const QString &dir)
{
    QDir qtDir(dir);
    if (!qtDir.exists()) {
        qWarning() << "Dir" << dir << "not found or not readable.";
        return;
    }

    m_dir = dir;
    m_dirWatcher.addPath(dir);

    updatePlaylist();
    updateAds();

    emit enabledChanged();
}

void MediaPlayer::playNext()
{
    m_playlistIndex++;
    m_playlist->setCurrentIndex(m_playlistIndex);
    qDebug() << "playNext" << m_playlist->currentIndex() << m_playlist->currentMedia().canonicalUrl().toString();
    emit movieIdChanged();
    play();

    updatePlaylist();
}

bool MediaPlayer::enabled() const
{
    if (m_dir.isEmpty())
        return false;

    QDir dir (m_dir);
    return dir.exists();
}

void MediaPlayer::updatePlaylist()
{
    auto count = m_playlist->mediaCount() - m_playlist->currentIndex() - 1;

    if (count < 3) {
        // Добавим новые тизеры в плейлист
        QDir dir (m_dir);

        auto files = dir.entryList(m_fileFilter, QDir::Files | QDir::Readable);

        QRegExp adsRx (R"(cph-(\d+))");

        QStringList teasers;

        for (auto file: files) {
            if (adsRx.indexIn(file) == -1)
                teasers << file;
        }

        while (teasers.count() < 3) {
            teasers << teasers;
        }

        std::random_shuffle(teasers.begin(), teasers.end());

        if (teasers.empty()) {
            qWarning() << "Not found teasers in" << m_dir;
        }

        for(auto file: teasers) {
            auto filePath = getFilePath(file);

            qDebug() << "Add new teaser to playlist:" << filePath;
            m_playlist->addMedia(QMediaContent(QUrl(filePath)));
        }
    }

    //Удалим старые ролики из плейлиста
    const auto maxIndex = 10;
    if (m_playlistIndex > maxIndex) {
        m_playlist->removeMedia(0, m_playlistIndex - 1);
        m_playlistIndex = 0;
    }
}

void MediaPlayer::checkAds()
{
    QDateTime currentDateTime = QDateTime::currentDateTime();
    if (m_ads.empty() || currentDateTime.secsTo(m_lastAdsShow) < m_adsPeriod)
        return;

    auto file = m_ads.takeFirst();
    m_lastAdsShow = currentDateTime;

    auto filePath = getFilePath(file);

    qDebug() << "Insert new ads to playlist:" << filePath;

    m_playlist->insertMedia(1, QMediaContent(QUrl(filePath)));

    if (m_ads.isEmpty())
        updateAds();
}

void MediaPlayer::updateAds()
{
    QDir dir (m_dir);

    auto files = dir.entryList(m_fileFilter, QDir::Files | QDir::Readable);

    QRegExp adsRx (R"(cph-(\d+))");

    QStringList ads;

    for (auto file: files) {
        if (adsRx.indexIn(file) != -1) {
            for (auto i = 0; i < adsRx.cap(1).toInt(); ++i) {
                ads << file;
            }
        }
    }

    std::random_shuffle(ads.begin(), ads.end());

    m_ads = ads;
    if (m_ads.empty()) {
        qWarning() << "Not found ads in" << m_dir;
        m_lastAdsShow = QDateTime();
    } else {
        m_lastAdsShow = QDateTime::currentDateTime();
        m_adsPeriod = 3600 / m_ads.count();
    }
}

QString MediaPlayer::getFilePath(const QString &file) const
{
    auto result = m_dir + QDir::separator() + file;
    return result.replace(QChar('\\'), QChar('/'));
}
