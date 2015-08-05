/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU Lesser General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef DOWNLOAD_H
#define DOWNLOAD_H

#include <QObject>
#include <QUrl>
#include <QVariantMap>
#include <QNetworkReply>
#include <QFile>
#include <qdeclarative.h>

class QNetworkAccessManager;
class QNetworkReply;

class Download : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QVariantMap headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileNameChanged)
    Q_PROPERTY(qint64 size READ size NOTIFY sizeChanged)
    Q_PROPERTY(qint64 bytesReceived READ bytesReceived NOTIFY progressChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(Error error READ error NOTIFY finished)
    Q_PROPERTY(QString errorString READ errorString NOTIFY finished)

    Q_ENUMS(Error)

public:
    enum Error {
        NoError = QNetworkReply::NoError,
        ConnectionRefusedError = QNetworkReply::ConnectionRefusedError,
        RemoteHostClosedError = QNetworkReply::RemoteHostClosedError,
        HostNotFoundError = QNetworkReply::HostNotFoundError,
        TimeoutError = QNetworkReply::TimeoutError,
        OperationCanceledError = QNetworkReply::OperationCanceledError,
        SslHandshakeFailedError = QNetworkReply::SslHandshakeFailedError,
        TemporaryNetworkFailureError = QNetworkReply::TemporaryNetworkFailureError,
        ProxyConnectionRefusedError = QNetworkReply::ProxyConnectionRefusedError,
        ProxyConnectionClosedError = QNetworkReply::ProxyConnectionClosedError,
        ProxyNotFoundError = QNetworkReply::ProxyNotFoundError,
        ProxyTimeoutError = QNetworkReply::ProxyTimeoutError,
        ProxyAuthenticationRequiredError = QNetworkReply::ProxyAuthenticationRequiredError,
        ContentAccessDenied = QNetworkReply::ContentAccessDenied,
        ContentOperationNotPermittedError = QNetworkReply::ContentOperationNotPermittedError,
        ContentNotFoundError = QNetworkReply::ContentNotFoundError,
        AuthenticationRequiredError = QNetworkReply::AuthenticationRequiredError,
        ContentReSendError = QNetworkReply::ContentReSendError,
        ProtocolUnknownError = QNetworkReply::ProtocolUnknownError,
        ProtocolInvalidOperationError = QNetworkReply::ProtocolInvalidOperationError,
        UnknownNetworkError = QNetworkReply::UnknownNetworkError,
        UnknownProxyError = QNetworkReply::UnknownProxyError,
        UnknownContentError = QNetworkReply::UnknownContentError,
        ProtocolFailure = QNetworkReply::ProtocolFailure,
        FileError = 1001
    };

    explicit Download(const QString &id, QObject *parent = 0);
    explicit Download(const QString &id, const QUrl &url, const QVariantMap &headers, const QString &fileName, qint64 size, qint64 received, QObject *parent = 0);
    ~Download();

    QString id() const;

    QUrl url() const;
    void setUrl(const QUrl &url);

    QVariantMap headers() const;
    void setHeaders(const QVariantMap &headers);

    QString fileName() const;
    void setFileName(const QString &fileName);

    qint64 size() const;
    qint64 bytesReceived() const;
    int progress() const;

    bool isRunning() const;

    Error error() const;
    QString errorString() const;

public Q_SLOTS:
    void queue();
    void start();
    void pause();
    void cancel();

private Q_SLOTS:
    void setSize(qint64 size);
    void setBytesReceived(qint64 received);
    void setProgress(int progress);

    void startDownload();
    void followRedirect(const QUrl &url);
    void onMetaDataChanged();
    void onReadyRead();
    void onReplyFinished();

Q_SIGNALS:
    void urlChanged();
    void headersChanged();
    void fileNameChanged();
    void sizeChanged();
    void progressChanged();
    void runningChanged();

    void queued(Download *download);
    void started(Download *download);
    void paused(Download *download);
    void canceled(Download *download);
    void finished(Download *download);
    
private:
    QNetworkAccessManager *m_nam;
    QNetworkReply *m_reply;

    QFile m_file;

    QString m_id;

    QUrl m_url;

    QVariantMap m_headers;

    QString m_fileName;

    qint64 m_size;
    qint64 m_received;
    int m_progress;

    Error m_error;
    QString m_errorString;

    int m_redirects;

    Q_DISABLE_COPY(Download)
};

QML_DECLARE_TYPE(Download)

#endif // DOWNLOAD_H
