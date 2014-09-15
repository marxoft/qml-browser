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
import org.hildon.webkit 1.0

ListView {
    id: view

    anchors {
        left: parent.left
        leftMargin: platformStyle.paddingMedium
        right: parent.right
        rightMargin: platformStyle.paddingMedium
        bottom: toolBar.top
    }
    focus: true
    height: Math.min(webHistory.count * 70, 280)
    autoFillBackground: true
    model: webHistory.urls
    horizontalScrollMode: ListView.ScrollPerItem
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    delegate: HistoryDelegate {}
    onFocusChanged: if ((!focus) && (!urlInput.focus)) viewLoader.sourceComponent = undefined;
    onActivated: {
        if (window.url) {
            window.url = webHistory.urls[QModelIndex.row(view.currentIndex)];
        }
        else {
            window.loadBrowserWindow(webHistory.urls[QModelIndex.row(view.currentIndex)]);
            urlInput.clear();
        }
    }
}
