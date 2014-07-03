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

import org.hildon.components 1.0
import org.hildon.utils 1.0

Dialog {
    id: root

    height: window.inPortrait ? 180 : 80
    windowTitle: qsTr("Settings")
    content: Column {
        anchors.fill: parent

        ValueButton {
            text: qsTr("Screen orientation")
            selector: ListSelector {
                model: [ qsTr("Landscape"), qsTr("Portrait"), qsTr("Automatic") ]
                currentIndex: settings.screenOrientation === Screen.AutoOrientation ? 2 : settings.screenOrientation === Screen.PortraitOrientation ? 1 : 0
                onSelected: {
                    switch (currentIndex) {
                    case 1:
                        settings.screenOrientation = Screen.PortraitOrientation;
                        return;
                    case 2:
                        settings.screenOrientation = Screen.AutoOrientation;
                        return;
                    default:
                        settings.screenOrientation = Screen.LandscapeOrientation;
                        return;
                    }
                }
            }
        }
    }

    buttons: Button {
        text: qsTr("Done")
        onClicked: root.accept()
    }
}
