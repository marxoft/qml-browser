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

bool Settings::useCustomURLHandlers() const {
    return this->value("useCustomURLHandlers", true).toBool();
}

void Settings::setUseCustomURLHandlers(bool use) {
    if (use != this->useCustomURLHandlers()) {
        this->setValue("useCustomURLHandlers", use);
        emit useCustomURLHandlersChanged();
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