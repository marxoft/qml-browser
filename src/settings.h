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

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QSettings>

class Settings : public QSettings
{
    Q_OBJECT

    Q_PROPERTY(bool forceToolBarVisibleWhenLoading READ forceToolBarVisibleWhenLoading WRITE setForceToolBarVisibleWhenLoading NOTIFY forceToolBarVisibleWhenLoadingChanged)
    Q_PROPERTY(bool openBrowserWindowsInFullScreen READ openBrowserWindowsInFullScreen WRITE setOpenBrowserWindowsInFullScreen NOTIFY openBrowserWindowsInFullScreenChanged)
    Q_PROPERTY(bool rotationEnabled READ rotationEnabled WRITE setRotationEnabled NOTIFY rotationEnabledChanged)
    Q_PROPERTY(bool zoomWithVolumeKeys READ zoomWithVolumeKeys WRITE setZoomWithVolumeKeys NOTIFY zoomWithVolumeKeysChanged)
    Q_PROPERTY(bool useCustomURLHandlers READ useCustomURLHandlers WRITE setUseCustomURLHandlers NOTIFY useCustomURLHandlersChanged)
    Q_PROPERTY(bool privateBrowsingEnabled READ privateBrowsingEnabled WRITE setPrivateBrowsingEnabled NOTIFY privateBrowsingEnabledChanged)
    Q_PROPERTY(bool autoLoadImages READ autoLoadImages WRITE setAutoLoadImages NOTIFY autoLoadImagesChanged)
    Q_PROPERTY(bool javaScriptEnabled READ javaScriptEnabled WRITE setJavaScriptEnabled NOTIFY javaScriptEnabledChanged)
    Q_PROPERTY(bool zoomTextOnly READ zoomTextOnly WRITE setZoomTextOnly NOTIFY zoomTextOnlyChanged)
    Q_PROPERTY(int defaultFontSize READ defaultFontSize WRITE setDefaultFontSize NOTIFY defaultFontSizeChanged)
    Q_PROPERTY(QString defaultTextEncoding READ defaultTextEncoding WRITE setDefaultTextEncoding NOTIFY defaultTextEncodingChanged)
    Q_PROPERTY(QString userAgentString READ userAgentString WRITE setUserAgentString NOTIFY userAgentStringChanged)

public:
    explicit Settings(QObject *parent = 0);
    ~Settings();

    bool forceToolBarVisibleWhenLoading() const;
    void setForceToolBarVisibleWhenLoading(bool force);

    bool openBrowserWindowsInFullScreen() const;
    void setOpenBrowserWindowsInFullScreen(bool fullScreen);

    bool rotationEnabled() const;
    void setRotationEnabled(bool enabled);

    bool zoomWithVolumeKeys() const;
    void setZoomWithVolumeKeys(bool zoom);

    bool useCustomURLHandlers() const;
    void setUseCustomURLHandlers(bool use);

    bool privateBrowsingEnabled() const;
    void setPrivateBrowsingEnabled(bool enabled);

    bool autoLoadImages() const;
    void setAutoLoadImages(bool load);

    bool javaScriptEnabled() const;
    void setJavaScriptEnabled(bool enabled);

    bool zoomTextOnly() const;
    void setZoomTextOnly(bool textOnly);

    int defaultFontSize() const;
    void setDefaultFontSize(int size);

    QString defaultTextEncoding() const;
    void setDefaultTextEncoding(const QString &encoding);

    QString userAgentString() const;
    void setUserAgentString(const QString &agent);

signals:
    void forceToolBarVisibleWhenLoadingChanged();
    void openBrowserWindowsInFullScreenChanged();
    void rotationEnabledChanged();
    void zoomWithVolumeKeysChanged();
    void useCustomURLHandlersChanged();
    void privateBrowsingEnabledChanged();
    void autoLoadImagesChanged();
    void javaScriptEnabledChanged();
    void zoomTextOnlyChanged();
    void defaultFontSizeChanged();
    void defaultTextEncodingChanged();
    void userAgentStringChanged();
    
private:
    Q_DISABLE_COPY(Settings)
};

#endif // SETTINGS_H
