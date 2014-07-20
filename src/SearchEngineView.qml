import org.hildon.components 1.0
import org.hildon.browser 1.0

ListView {
    id: view

    property string query

    model: searchEngines
    horizontalScrollMode: ListView.ScrollPerItem
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    delegate: ListItem {
        width: view.width
        height: 70

        ListItemImage {
            anchors.fill: parent
            source: isCurrentItem ? "file:///etc/hildon/theme/images/TouchListBackgroundPressed.png"
                                  : "file:///etc/hildon/theme/images/TouchListBackgroundNormal.png"
        }

        ListItemText {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: image.left
                margins: 10
            }
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            text: modelData.name + " " + qsTr("Search") + ": '" + view.query + "'"
        }

        ListItemImage {
            id: image

            width: 64
            height: 64
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            source: "file://" + modelData.icon
            smooth: true
        }
    }
    onQueryChanged: { view.height += 1; view.height -= 1 } // Hotfix to ensure the delegate paint() method is called.
}
