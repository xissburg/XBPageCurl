# XBPageCurl

XBPageCurl is a free and open-source implementation of a page curl animation/transition for views in iOS that intends to mimic the behavior of the pages in apps like iBooks and GoogleMaps for iOS.

It uses OpenGL ES 2.0 to draw a deformed mesh of triangles. Conceptually, it projects the vertices of the mesh on a virtual cylinder that rolls on the view. You can move, rotate and change the radius of the cylinder, with or without animation. The mesh follows the cylinder as it moves. The mesh deformation is performed in a crazy vertex shader which makes it really fast.

![Uncurled](http://xissburg.com/images/XBPageCurlMap.png)  ![Curled](http://xissburg.com/images/XBPageCurlMapCurled.png)

## Concepts

The concept behind this page curl effect is that of a virtual cylinder that slides on top of the page and everything that is on the right of this cylinder curls around it till the top of the cylinder and then it continues in a horizontal flat plane, hence showing the back of the page. The cylinder can be moved and rotated and its radius can change. The position of the cylinder is actually any point in its axis projected on the xy-plane, hence any point in the same axis results in the same cylinder.

![Concept](http://xissburg.com/images/XBPageCurlConcept.png) 

## How to use

Basically, XBPageCurl can be used in two different ways. It can be used to curl a view and show another view behind it where the user can interact with its elements and then uncurl the view back, pretty much like in the Google Maps app (Simple Curl sample). It can also be used to flip pages like in iBooks, where the user can drag the border of a page and release to flip it or cancel the flip (Page Curl sample).

### Using XBCurlView

XBCurlView is a low level class that does the actual work for curling the view. It has methods for drawing views or images in one of its three pages (front and back of the page being curled and the next page) and for controlling the cylinder that moves around on top the curling view. It can be used to curl a view to show another view behind it like in Google Maps, or to do another customized view curl transition.

To use it, you first have to initialize an instance using the initializer that best satisfies your needs. The `initWithFrame:` initializer is a good start, it will create a grid mesh with a resolution proportional to the frame size, which gives good results for cylinder radius above 20. The `initWithFrame:antialiasing:` allows you to specify whether you want to switch on the Open GL ES Multisampling Antialiasing to get smoother edges. The `initWithFrame:horizontalResolution:verticalResolution:antialiasing` allows you to choose the mesh resolution (amount of rows and columns on the grid mesh), which you should try to keep proportional to the frame size in order to get a grid of squares, not rectangles. You should only worry about the mesh resolution if you start to see the shapes of the triangles on the curled section of the mesh, which can be smoothed out by increasing the resolution.

A simple way to curl an arbitrary view is to call the helper methods `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]` which will do all the work for adding the XBCurlView instance as subview and removing the view to be curled from its superview and then add it back after the uncurl animation. Its usage is self explanatory and you can see an example of its usage in the RootViewController's button actions methods in the sample application.

If you want more control, you have to handle the setup process yourself, which will usually look pretty much like the steps taken in the `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]` methods. After you initialize a XBCurlView instance, you should draw the view or image you want to curl on it using `drawViewOnFrontOfPage:` or `drawImageOnFrontOfPage:`, which draws the view or image in the front of the mesh that will curl. You should also set opaque to NO on the XBCurlView instance in order to see through it on the region the page does not cover, which allows you to see the views behind the XBCurlView and interact with them. 

To curl the view back, just set its cylinder position, orientation and radius back to initial state with animation and for one of them assign a completion block that should add the original view back again, remove the XBCurlView instance from its superview and also call stopAnimating to stop the OpenGL ES rendering loop.

```objective-c
//Initializing a XBCurlView instance in viewDidLoad in the root view controller
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    CGRect r = CGRectZero;
    r.size = self.view.bounds.size;
    self.curlView = [[[XBCurlView alloc] initWithFrame:r] autorelease];
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    self.curlView.opaque = NO;
}
```

Whenever you want to curl the view, first draw it again on the front of the page to update the image on the curling mesh,  set the initial cylinder properties, then set the final properties with animation, add the XBCurlView instance as a subview of the superview of the view you are gonna curl so that it is above that view, and remove the other view from its superview so that the other view behind it will appear. Lastly, you have to call `startAnimating` on the XBCurlView instance for it to start rendering the OpenGL ES stuff. You can stop the animation with `stopAnimating` after the animation completes (use the animation completion block for that).

```objective-c
GRect frame = self.view.frame;
double angle = M_PI/2.5;
//Reset cylinder properties, positioning it on the right side, oriented vertically
self.curlView.cylinderPosition = CGPointMake(frame.size.width, frame.size.height/2);
self.curlView.cylinderAngle = M_PI_2;
self.curlView.cylinderRadius = 20;
//Update the view drawn on the front of the curling page
[self.curlView drawViewOnFrontOfPage:self.messyView];
//Start the cylinder animation
[self.curlView setCylinderPosition:CGPointMake(frame.size.width/6, frame.size.height/2) animatedWithDuration:kDuration];
[self.curlView setCylinderDirection:CGPointMake(cos(angle), sin(angle)) animatedWithDuration:kDuration];
[self.curlView setCylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration completion:^{
    [self stopAnimating]; //Stop the OpenGL animation loop after these animations are finished
}];
//Setup the view hierarchy
[self.view addSubview:self.curlView];
[self.messyView removeFromSuperview];
//Start the rendering loop
[self.curlView startAnimating];
```

To curl the view back, just set its cylinder position, orientation and radius with animation and for one of them assign a completion block that should add the original view back again, remove the XBCurlView instance from its superview and also call stopAnimating to stop the rendering loop. 

```objective-c
CGRect frame = self.view.frame;
//Animate the cylinder back to its start position at the right side of the screen, oriented vertically
[self.curlView setCylinderPosition:CGPointMake(frame.size.width, frame.size.height/2) animatedWithDuration:kDuration];
[self.curlView setCylinderDirection:CGPointMake(0,1) animatedWithDuration:kDuration];
[self.curlView setCylinderRadius:20 animatedWithDuration:kDuration completion:^(void) {
    //Setup the view hierarchy properly after the animation is finished
    [self.view addSubview:self.messyView];
    [self.curlView removeFromSuperview];
    //Stop the rendering loop since the curlView won't appear at the moment
    [self.curlView stopAnimating];
}];
//Start the rendering loop
[self.curlView startAnimating];
```
You can find a working implementation of these steps in `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]`.

Note that the XBCurlView does not support frame changes while it is rendering. Hence be careful when doing interface orientation changes.

### Using XBPageCurlView

XBPageCurlView is a view that has support for dragging the page with a finger like in a book. It is a subclass of XBCurlView that adds touch handling to it. It controls the cylinder so that the corner of the page will follow the user's finger. It also supports snapping points (XBSnappingPoint class) that the cylinder can stick to and a protocol that warns its delegate before and after sticking to a snapping point. The usage is pretty much the same as the XBCurlView.

### XBPageDragView

XBPageDragView is a view that will automatically create and animate a XBPageCurlView whenever a finger is dragged on it. Just create one instance of it (in Interface Builder or programmatically), set the view it should curl in its `viewToCurl` property and you're all set. Since the page mesh depends on the size of the view to curl, you should call `-[XBPageDragView refreshPageCurlView]` whenever the frame of that view changes. Look into PageCurlViewController* for details.
