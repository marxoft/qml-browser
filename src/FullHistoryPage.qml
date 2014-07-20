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

Page {
    id: root

    windowTitle: qsTr("Complete browsing history")

    ListView {
        id: view

        anchors.fill: parent
        model: webHistory.urls.reverse()
        onClicked: {
            var url = view.model[QModelIndex.row(view.currentIndex)].toString();

            if (url !== window.url.toString()) {
                window.url = url;
            }

            pageStack.pop(window);
        }
    }

    Label {
        anchors {
            fill: parent
            margins: 10
        }
        alignment: Qt.AlignCenter
        font {
            bold: true
            pixelSize: 40
        }
        color: platformStyle.secondaryTextColor
        text: qsTr("No history")
        visible: webHistory.urls.length === 0
    }
}