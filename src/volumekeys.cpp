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

#include "volumekeys.h"
#include <QX11Info>
#include <X11/Xlib.h>
#include <X11/Xatom.h>

VolumeKeys::VolumeKeys(QObject *parent) :
    QObject(parent)
{
}

VolumeKeys::~VolumeKeys() {}

bool VolumeKeys::grab(QObject *window) {
    if (window->isWidgetType()) {
        return grabVolumeKeys(qobject_cast<QWidget*>(window)->winId(), true);
    }

    return false;
}

bool VolumeKeys::release(QObject *window) {
    if (window->isWidgetType()) {
        return grabVolumeKeys(qobject_cast<QWidget*>(window)->winId(), false);
    }

    return false;
}

bool VolumeKeys::grabVolumeKeys(WId windowId, bool grab) {
    if (!windowId) {
        qWarning("Can't grab keys unless we have a window id");
        return false;
    }

    unsigned long val = (grab) ? 1 : 0;
    Atom atom = XInternAtom(QX11Info::display(), "_HILDON_ZOOM_KEY_ATOM", False);

    if (!atom) {
        qWarning("Unable to obtain _HILDON_ZOOM_KEY_ATOM. This example will only work "
                 "on a Maemo 5 device!");
        return false;
    }

    XChangeProperty (QX11Info::display(),
                     windowId,
                     atom,
                     XA_INTEGER,
                     32,
                     PropModeReplace,
                     reinterpret_cast<unsigned char *>(&val),
                     1);

    return true;
}
