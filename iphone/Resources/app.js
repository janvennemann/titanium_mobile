/**
 * This file is used to validate iOS test-cases. It is ran using the Xcode
 * project in titanium_mobile/iphone/iphone/Titanium.xcodeproj.
 *
 * Change the below code to fit your use-case. By default, it included a button
 * to trigger a log that is displayed in the Xcode console.
 */

const createFlexView = (name, style) => {
  const view = Ti.UI.createView({
    style: {
      justifyContent: 'center',
      alignItems: 'center',
      ...style
    }
  });
  const label = Ti.UI.createLabel({ text: name });
  view.add(label);
  return view;
}

var win = Ti.UI.createWindow({
    style: {
      backgroundColor: '#FAFAFA',
      width: '100%',
      flexWrap: 'wrap'
    }
});

const verticalContainer = Ti.UI.createView({
  style: {
    paddingTop: 50,
    width: '100%'
  }
});

const vert1 = createFlexView('View 1', {
  backgroundColor: '#5E35B1',
  height: 100,
  width: '33.333%'
});
verticalContainer.add(vert1);
const vert2 = createFlexView('View 2', {
  backgroundColor: '#3F51B5',
  height: 100,
  width: '33.333%'
});
verticalContainer.add(vert2);
const vert3 = createFlexView('View 3', {
  backgroundColor: '#2196F3',
  height: 100,
  width: '33.333%'
});
verticalContainer.add(vert3);

const horizontalContainer = Ti.UI.createView({
  style: {
    paddingTop: 50,
    width: '100%',
    flexDirection: 'column'
  }
});
const hori1 = createFlexView('View 1', {
  backgroundColor: '#00BCD4',
  height: 100,
  width: '100%'
});
horizontalContainer.add(hori1);
const hori2 = createFlexView('View 2', {
  backgroundColor: '#009688',
  height: 100,
  width: '100%'
});
horizontalContainer.add(hori2);

win.add(verticalContainer);
win.add(horizontalContainer);

win.open();
