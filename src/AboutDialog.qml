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

Dialog {
    id: root

    height: window.inPortrait ? 260 : 160
    windowTitle: qsTr("About")
    content: Row {
        anchors.fill: parent

        Image {
            width: 64
            height: 64
            source: "file:///usr/share/icons/hicolor/64x64/hildon/general_web.png"
        }

        Label {
            wordWrap: true
            text: "<b><font size='4'>QML Browser 0.1.0</font></b><br><br>" + qsTr("A simple web browser written using Qt Components Hildon.")
        }
    }

    buttons: Button {
        text: qsTr("Done")
        onClicked: root.accept()
    }
}
