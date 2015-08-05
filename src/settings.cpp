/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "settings.h"

Settings::Settings(QObject *parent) :
    QSettings("QMLBrowser", "QMLBrowser", parent)
{
}

Settings::~Settings() {}

bool Settings::forceToolBarVisibleWhenLoading() const {
    return value("forceToolBarVisibleWhenLoading", true).toBool();
}

void Settings::setForceToolBarVisibleWhenLoading(bool force) {
    if (force != forceToolBarVisibleWhenLoading()) {
        setValue("forceToolBarVisibleWhenLoading", force);
        emit forceToolBarVisibleWhenLoadingChanged();
    }
}

bool Settings::openBrowserWindowsInFullScreen() const {
    return value("openBrowserWindowsInFullScreen", false).toBool();
}

void Settings::setOpenBrowserWindowsInFullScreen(bool fullScreen) {
    if (fullScreen != openBrowserWindowsInFullScreen()) {
        setValue("openBrowserWindowsInFullScreen", fullScreen);
        emit openBrowserWindowsInFullScreenChanged();
    }
}

bool Settings::rotationEnabled() const {
    return value("rotationEnabled", false).toBool();
}

void Settings::setRotationEnabled(bool enabled) {
    if (enabled != rotationEnabled()) {
        setValue("rotationEnabled", enabled);
        emit rotationEnabledChanged();
    }
}

bool Settings::zoomWithVolumeKeys() const {
    return value("zoomWithVolumeKeys", false).toBool();
}

void Settings::setZoomWithVolumeKeys(bool zoom) {
    if (zoom != zoomWithVolumeKeys()) {
        setValue("zoomWithVolumeKeys", zoom);
        emit zoomWithVolumeKeysChanged();
    }
}

bool Settings::useCustomURLHandlers() const {
    return value("useCustomURLHandlers", true).toBool();
}

void Settings::setUseCustomURLHandlers(bool use) {
    if (use != useCustomURLHandlers()) {
        setValue("useCustomURLHandlers", use);
        emit useCustomURLHandlersChanged();
    }
}

bool Settings::privateBrowsingEnabled() const {
    return value("Content/privateBrowsingEnabled", false).toBool();
}

void Settings::setPrivateBrowsingEnabled(bool enabled) {
    if (enabled != privateBrowsingEnabled()) {
        setValue("Content/privateBrowsingEnabled", enabled);
        emit privateBrowsingEnabledChanged();
    }
}

bool Settings::autoLoadImages() const {
    return value("Content/autoLoadImages", true).toBool();
}

void Settings::setAutoLoadImages(bool load) {
    if (load != autoLoadImages()) {
        setValue("Content/autoLoadImages", load);
        emit autoLoadImagesChanged();
    }
}

bool Settings::javaScriptEnabled() const {
    return value("Content/javaScriptEnabled", true).toBool();
}

void Settings::setJavaScriptEnabled(bool enabled) {
    if (enabled != javaScriptEnabled()) {
        setValue("Content/javaScriptEnabled", enabled);
        emit javaScriptEnabledChanged();
    }
}

bool Settings::zoomTextOnly() const {
    return value("Content/zoomTextOnly", false).toBool();
}

void Settings::setZoomTextOnly(bool textOnly) {
    if (textOnly != zoomTextOnly()) {
        setValue("Content/zoomTextOnly", textOnly);
        emit zoomTextOnlyChanged();
    }
}

int Settings::defaultFontSize() const {
    return value("Content/defaultFontSize", 16).toInt();
}

void Settings::setDefaultFontSize(int size) {
    if (size != defaultFontSize()) {
        setValue("Content/defaultFontSize", size);
        emit defaultFontSizeChanged();
    }
}

QString Settings::defaultTextEncoding() const {
    return value("Content/defaultTextEncoding", "UTF-8").toString();
}

void Settings::setDefaultTextEncoding(const QString &encoding) {
    if (encoding != defaultTextEncoding()) {
        setValue("Content/defaultTextEncoding", encoding);
        emit defaultTextEncodingChanged();
    }
}

QString Settings::userAgentString() const {
    return value("Content/userAgentString").toString();
}

void Settings::setUserAgentString(const QString &agent) {
    if (agent != userAgentString()) {
        setValue("Content/userAgentString", agent);
        emit userAgentStringChanged();
    }
}
