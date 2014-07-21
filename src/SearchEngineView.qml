import org.hildon.components 1.0
import org.hildon.browser 1.0

ListView {
    id: view

    property string query

    visible: (searchEngines.count) && (query) && ((focus) || (urlInput.focus))
    maximumHeight: Math.min(searchEngines.count, 3) * 70
    styleSheet: "background-color: " + platformStyle.defaultBackgroundColor + "; border: 1px solid " + platformStyle.disabledTextColor + ";"
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
            text: modelData.name + (row === searchEngines.count - 1 ? "" : " " + qsTr("Search") + ": '" + view.query + "'")
        }

        ListItemImage {
            id: image

            width: 48
            height: 48
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            source: "file://" + modelData.icon
            smooth: true
        }
    }
    onQueryChanged: { height += 1; height -= 1 } // Hotfix to ensure the delegate paint() method is called.
    onClicked: {
        switch (QModelIndex.row(currentIndex)) {
        case searchEngines.count - 1:
        {
            loader.source = Qt.resolvedUrl("NewSearchEngineDialog.qml");
            loader.item.open();
            break;
        }
        default:
        {
            window.loadBrowserWindow(searchEngines.data(currentIndex, SearchEngineModel.UrlRole).toString().replace(/%QUERY%/ig, query.replace(/\s+/g, "+")));
            urlInput.clear();
            break;
        }
        }
    }
}
