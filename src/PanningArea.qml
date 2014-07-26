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

MouseArea {
    id: root

    property bool panningOn: false
    property bool pointerOn: false

    QtObject {
        id: internal

        property bool enteredFromLeft: false
        property bool enteredFromRight: false
    }

    Image {
        x: root.mouseX
        y: root.mouseY
        width: 32
        height: 32
        source: "file:///usr/share/icons/hicolor/32x32/hildon/browser_cursor.png"
        visible: root.pointerOn
    }

    Timer {
        interval: 2000
        running: (!root.panningOn) && (!root.pressed)
        onTriggered: {
            root.pointerOn = false;
            root.panningOn = false;
        }
    }

    Timer {
        interval: 50
        repeat: true
        running: (root.pressed) && (root.pointerOn) && (!root.panningOn) && (((root.mouseY < 10) && (!webView.atYBeginning)) || ((root.mouseY > (root.height - 10)) && (!webView.atYEnd)))
        onTriggered: root.mouseY < 10 ? webView.contentY -= Math.abs(10 - root.mouseY) * 5 : webView.contentY += Math.abs(root.height - 10 - root.mouseY) * 5
    }

    Timer {
        interval: 50
        repeat: true
        running: (root.pressed) && (root.pointerOn) && (!root.panningOn) && (((root.mouseX < 10) && (!webView.atXBeginning)) || ((root.mouseX > (root.width - 10)) && (!webView.atXEnd)))
        onTriggered: root.mouseX < 10 ? webView.contentX -= Math.abs(10 - root.mouseX) * 5 : webView.contentX += Math.abs(root.width - 10 - root.mouseX) * 5
    }

    onPressed: {
        internal.enteredFromLeft = (mouseX < 5);
        internal.enteredFromRight = (mouseX > (width - 5));
    }

    onPositionChanged: {
        if (internal.enteredFromLeft) {
            if (mouseX > 10) {
                pointerOn = true;
                internal.enteredFromLeft = false;
            }
        }
        else if (internal.enteredFromRight) {
            if (mouseX < (width - 10)) {
                pageStack.push(Qt.resolvedUrl("RecentHistoryPage.qml"), {})
                internal.enteredFromRight = false;
            }
        }
    }
}
