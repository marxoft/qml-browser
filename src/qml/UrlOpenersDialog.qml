/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
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
import org.hildon.browser 1.0

Dialog {
    id: root
    
    title: qsTr("URL handlers")
    height: 360
    
    ListView {
        id: view
        
        anchors {
            left: parent.left
            right: button.left
            rightMargin: platformStyle.paddingMedium
            top: parent.top
            bottom: parent.bottom
        }
        model: urlopener
        delegate: UrlOpenerDelegate {
            onClicked: popupManager.open(urlOpenerDialog, root, {regExp: name, command: value})
            onPressAndHold: popupManager.open(contextMenu, root)
        }
    }
    
    Label {
        anchors.fill: view
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: platformStyle.disabledTextColor
        text: qsTr("(No URL handlers)")
        visible: urlopener.count == 0
    }
        
    Button {
        id: button
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        style: DialogButtonStyle {}
        text: qsTr("New")
        onClicked: popupManager.open(urlOpenerDialog, root)
    }
    
    Component {
        id: contextMenu
        
        Menu {        
            MenuItem {
                text: qsTr("Edit")
                onTriggered: popupManager.open(urlOpenerDialog, root,
                {regExp: urlopener.data(view.currentIndex, SelectionModel.NameRole),
                 commend: urlopener.data(view.currentIndex, SelectionModel.ValueRole)})
            }
            
            MenuItem {
                text: qsTr("Delete")
                onTriggered: {
                    urlopener.remove(view.currentIndex);
                    urlopener.save();
                }
            }
        }
    }
    
    Component {
        id: urlOpenerDialog
        
        UrlOpenerDialog {
            onAccepted: {
                urlopener.append(regExp, command);
                urlopener.save();
            }
        }
    }    
}
