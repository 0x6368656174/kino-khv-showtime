#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFontDatabase>
#include <QDebug>
#include <IqC4Mobile>
#include <QTimer>
#include <QCommandLineParser>
#include <IqC4MobileShowRepository>
#include <IqC4MobileQmlNetworkAccessManagerFactory>
#include "mediaplayer.h"
#include <ctime>

int main(int argc, char *argv[])
{
    srand(time(0));

    QDir dir (":/src/fonts/");

    QGuiApplication app(argc, argv);
    app.setOrganizationName("itQuasar");
    app.setApplicationName("showtime");
    app.setOrganizationDomain("kino-khv.ru");
    app.setApplicationVersion("1.0.0");

    QCommandLineParser parser;
    parser.setApplicationDescription("Отображает рассписание сеансов группы кинотеатров #Кинокхв.\n\nАвтор: Павел Пучков (0x6368656174@gmail.com)");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption fullScreen (QStringList() << "f" << "full-screen", "Запустить развернутой на весь экран.");
    parser.addOption(fullScreen);

    QCommandLineOption url ("url", "Адресс сайта #Кинокхв. По-умолчанию: https://kino-khv.ru", "url", "https://kino-khv.ru");
    parser.addOption(url);

    QCommandLineOption pageTime (QStringList() << "t" << "page-time", "<Время> отображения одной страницы расписания в секундах. По-умолчанию: 16.", "время", "16");
    parser.addOption(pageTime);

    QCommandLineOption pageAnimation (QStringList() << "page-animation-duration", "<Длительность> анимации прокрутки страницы расписания в миллисекундах. По-умолчанию: 600.", "длительность", "600");
    parser.addOption(pageAnimation);

    QCommandLineOption cinema (QStringList() << "c" << "cinema", "<Имя> кинотеатра для которого будет загружено расписание. Доступны следующие имена: khabarovsk, atmosfera, forum, drujba. По-умолчанию: khabarovsk.", "имя", "khabarovsk");
    parser.addOption(cinema);

    QCommandLineOption showtimeReloadInterval (QStringList() << "r" << "reload-interval", "<Интервал> между перезагрузками расписания с сайта #Кинокхв. По-умолчанию: 3600.", "интервал", "3600");
    parser.addOption(showtimeReloadInterval);

    QCommandLineOption teaserDir (QStringList() << "d" << "teasers-dir", "<Путь к папке>, в которой храняться ролики. Если не указывать, то ролики воспроизводиться не будут.", "путь к папке");
    parser.addOption(teaserDir);

    QCommandLineOption showtimeTime (QStringList() << "s" << "showtime-time", "<Время> отображения расписания сеансов в секундах. Если установить в 0, то расписание сеансов отображаться не будет. По-умолчанию: 16.", "время", "16");
    parser.addOption(showtimeTime);

    QCommandLineOption afterMovieDialogTime ("movie-dialog-time", "<Время> отображения диалога после ролика в секундах. Если установить в 0, то диалог после ролика отображаться не будет. По-умолчанию: 5.", "время", "5");
    parser.addOption(afterMovieDialogTime);

    parser.process(app);

    IqC4Mobile::instance()->setBaseUrl(QUrl("https://kino-khv.ru"));

    QTimer reloadTimer;
    reloadTimer.setSingleShot(false);
    reloadTimer.start(parser.value(showtimeReloadInterval).toInt() * 1000);
    QObject::connect(&reloadTimer, &QTimer::timeout, &app, []() {
        IqC4MobileShowRepository::instance()->reload();
    });

    MediaPlayer mediaPlayer;
    if (parser.isSet(teaserDir))
        mediaPlayer.setDir(parser.value(teaserDir));

    // GUI
    for (const QString &fontFileName: dir.entryList()) {
        QFontDatabase::addApplicationFont(":/src/fonts/" + fontFileName);
    }

    IqC4MobileQmlNetworkAccessManagerFactory networkAccessManagerFactory;

    QQmlApplicationEngine engine;
    engine.setNetworkAccessManagerFactory(&networkAccessManagerFactory);

    engine.rootContext()->setContextProperty("cinemaName", parser.value(cinema));
    engine.rootContext()->setContextProperty("fullSceen", parser.isSet(fullScreen));
    engine.rootContext()->setContextProperty("pageTime", parser.value(pageTime).toInt() * 1000);
    engine.rootContext()->setContextProperty("pageAnimationDuration", parser.value(pageAnimation).toInt());
    engine.rootContext()->setContextProperty("showtimeTime", parser.value(showtimeTime).toInt() * 1000);
    engine.rootContext()->setContextProperty("movieDialogTime", parser.value(afterMovieDialogTime).toInt() * 1000);
    engine.rootContext()->setContextProperty("mediaPlayer", &mediaPlayer);

    engine.load(QUrl(QStringLiteral("qrc:/src/qml/main.qml")));

    return app.exec();
}
