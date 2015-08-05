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

import QtQuick 1.0
import org.hildon.components 1.0

MouseArea {
    id: root

    property bool panningOn: false
    property bool pointerOn: false
    
    hoverEnabled: true

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
        source: "image://icon/browser_cursor"
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
        running: (root.pressed) && (root.pointerOn) && (!root.panningOn) && (((root.mouseY < 10) && (!flicker.atYBeginning))
                 || ((root.mouseY > (root.height - 10)) && (!flicker.atYEnd)))
        onTriggered: root.mouseY < 10 ? flicker.contentY -= Math.abs(10 - root.mouseY) * 5
                                      : flicker.contentY += Math.abs(root.height - 10 - root.mouseY) * 5
    }

    Timer {
        interval: 50
        repeat: true
        running: (root.pressed) && (root.pointerOn) && (!root.panningOn) && (((root.mouseX < 10) && (!flicker.atXBeginning))
                 || ((root.mouseX > (root.width - 10)) && (!flicker.atXEnd)))
        onTriggered: root.mouseX < 10 ? flicker.contentX -= Math.abs(10 - root.mouseX) * 5
                                      : flicker.contentX += Math.abs(root.width - 10 - root.mouseX) * 5
    }

    onPressed: {
        mouse.accepted = pointerOn;
        
        if (!pointerOn) {
            internal.enteredFromLeft = (mouseX < 10);
            internal.enteredFromRight = (mouseX > (width - 10));
        }
    }

    onPositionChanged: {
        if (!pointerOn) {
            if (internal.enteredFromLeft) {
                if (mouseX > 10) {
                    pointerOn = true;
                    internal.enteredFromLeft = false;
                }
            }
            else if (internal.enteredFromRight) {
                if (mouseX < (width - 10)) {
                    windowStack.push(Qt.resolvedUrl("RecentHistoryWindow.qml"), {})
                    internal.enteredFromRight = false;
                }
            }
        }
    }
}
