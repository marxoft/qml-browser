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

#include "settings.h"

Settings::Settings(QObject *parent) :
    QSettings("QMLBrowser", "QMLBrowser", parent)
{
}

Settings::~Settings() {}

bool Settings::forceToolBarVisibleWhenLoading() const {
    return this->value("forceToolBarVisibleWhenLoading", true).toBool();
}

void Settings::setForceToolBarVisibleWhenLoading(bool force) {
    if (force != this->forceToolBarVisibleWhenLoading()) {
        this->setValue("forceToolBarVisibleWhenLoading", force);
        emit forceToolBarVisibleWhenLoadingChanged();
    }
}

bool Settings::openBrowserWindowsInFullScreen() const {
    return this->value("openBrowserWindowsInFullScreen", false).toBool();
}

void Settings::setOpenBrowserWindowsInFullScreen(bool fullScreen) {
    if (fullScreen != this->openBrowserWindowsInFullScreen()) {
        this->setValue("openBrowserWindowsInFullScreen", fullScreen);
        emit openBrowserWindowsInFullScreenChanged();
    }
}

bool Settings::rotationEnabled() const {
    return this->value("rotationEnabled", false).toBool();
}

void Settings::setRotationEnabled(bool enabled) {
    if (enabled != this->rotationEnabled()) {
        this->setValue("rotationEnabled", enabled);
        emit rotationEnabledChanged();
    }
}

bool Settings::zoomWithVolumeKeys() const {
    return this->value("zoomWithVolumeKeys", false).toBool();
}

void Settings::setZoomWithVolumeKeys(bool zoom) {
    if (zoom != this->zoomWithVolumeKeys()) {
        this->setValue("zoomWithVolumeKeys", zoom);
        emit zoomWithVolumeKeysChanged();
    }
}

bool Settings::useCustomURLHandlers() const {
    return this->value("useCustomURLHandlers", true).toBool();
}

void Settings::setUseCustomURLHandlers(bool use) {
    if (use != this->useCustomURLHandlers()) {
        this->setValue("useCustomURLHandlers", use);
        emit useCustomURLHandlersChanged();
    }
}

bool Settings::privateBrowsingEnabled() const {
    return this->value("Content/privateBrowsingEnabled", false).toBool();
}

void Settings::setPrivateBrowsingEnabled(bool enabled) {
    if (enabled != this->privateBrowsingEnabled()) {
        this->setValue("Content/privateBrowsingEnabled", enabled);
        emit privateBrowsingEnabledChanged();
    }
}

bool Settings::autoLoadImages() const {
    return this->value("Content/autoLoadImages", true).toBool();
}

void Settings::setAutoLoadImages(bool load) {
    if (load != this->autoLoadImages()) {
        this->setValue("Content/autoLoadImages", load);
        emit autoLoadImagesChanged();
    }
}

bool Settings::javaScriptEnabled() const {
    return this->value("Content/javaScriptEnabled", true).toBool();
}

void Settings::setJavaScriptEnabled(bool enabled) {
    if (enabled != this->javaScriptEnabled()) {
        this->setValue("Content/javaScriptEnabled", enabled);
        emit javaScriptEnabledChanged();
    }
}

int Settings::defaultFontSize() const {
    return this->value("Content/defaultFontSize", 16).toInt();
}

void Settings::setDefaultFontSize(int size) {
    if (size != this->defaultFontSize()) {
        this->setValue("Content/defaultFontSize", size);
        emit defaultFontSizeChanged();
    }
}

QString Settings::defaultTextEncoding() const {
    return this->value("Content/defaultTextEncoding", "UTF-8").toString();
}

void Settings::setDefaultTextEncoding(const QString &encoding) {
    if (encoding != this->defaultTextEncoding()) {
        this->setValue("Content/defaultTextEncoding", encoding);
        emit defaultTextEncodingChanged();
    }
}
