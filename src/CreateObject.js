function createObject(sourceFile, parentObject) {
    var component = Qt.createComponent(sourceFile);
    
    if (component.status == 1) {
        var guiObject = component.createObject(parentObject);
        
        if (guiObject === null) {
            console.log("Error creating object");
        }
        else {
            return guiObject
        }
    }
    else {
        console.log(component.errorString());
    }
}