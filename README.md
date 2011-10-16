# XBPageCurl

XBPageCurl is a free and open-source implementation of a page curl animation/transition for views in iOS that intends to mimic the behavior of the pages in apps like iBooks and GoogleMaps for iOS.

It uses OpenGL ES 2 to draw a deformed mesh of triangles. Conceptually, it projects the vertices of the mesh on a virtual cylinder that touches the view. You can move, rotate and change the radius of the cylinder, with or without animation. This will make the mesh curl around the cylinder. The mesh deformation is performed in a vertex shader which makes it really fast.

![Uncurled](http://xissburg.com/images/Uncurled_0.png)  ![Curled](http://xissburg.com/images/Curled_0.png)
![CurledLandscape](http://xissburg.com/images/CurledLandscape_0.png)

## Concepts

The concept behind this page curl effect is that of a virtual cylinder that moves on top of the page and everything that is at the right of this cylinder curls around it till the top of the cylinder and then it continues in a horizontal flat plane, hence showing the back of the page. The cylinder can be moved and rotated and its radius can change. The position of the cylinder is actually any point in its axis projected on the xy-plane, hence any point in the same axis results in the same cylinder.

## How to use

Basically, XBPageCurl can be used in two different ways. It can be used to curl a view and show another view behind it where the user can interact with its elements and then uncurl the view back, pretty much like in the Google Maps app. It can also be used to flip pages like in iBooks, where the user can drag the border of a page and release to flip it or cancel the flip.

### Using XBCurlView

XBCurlView is a low level class that does the actual work for curling the view. It has methods for drawing views or images in one of its three pages (front and back of the page being curled and the next page) and for controlling the cylinder that moves around on top the curling view. It can be used to curl a view to show another view behind it like in Google Maps, or to do another customized view curl transition.

To use it, you first have to initialize an instance using the initializer that best satisfies your needs. The initWithFrame: initializer is a good start, it will create a grid mesh with a resolution proportional to the frame size, which gives good results for cylinder radius above 20. The initWithFrame:antialiasing: allows you to specify whether you want to switch the Open GL ES Multisampling Antialiasing on to get smoother edges. The initWithFrame:horizontalResolution:verticalResolution:antialiasing allows you to choose the mesh resolution (amount of rows and columns on the grid mesh), which you should try to keep proportional to the frame size in order to get a grid of squares, not rectangles. You should only worry about the mesh resolution if you start to see the edges of the triangles at the curled section of the mesh, which can be smoothed out by increasing the resolution.

A simple way to curl an arbitrary view is to call the helper methods `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]` which will do all the work for adding the XBCurlView instance as subview and removing the view to be curled from its superview and then add it back after the uncurl animation. Its usage is self explanatory and you can see an example of its usage in the RootViewController's button actions methods in the sample application.

If you want more control, you have to handle the setup process yourself, which will usually look pretty much like the steps taken in the `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]` methods. After you initialize a XBCurlView instance, you should draw the view or image you want to curl on it using drawViewOnFrontOfPage: or drawImageOnFrontOfPage:, which draws the view or image in the front of the mesh that will curl (in the near future it will be possible to draw another view on the back of this mesh using the methods drawViewOnBackOfPage: or drawImageOnBackOfPage:) to avoid a glitch. You should also set opaque to NO on the XBCurlView instance in order to see through it on the region where no opaque pixels are drawn. 

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

Whenever you want to curl the view, first draw it again on the front of the page to update the image on the curling mesh,  set the initial cylinder properties, then set the final properties with animation, add the XBCurlView instance as a subview of the superview of the view you are gonna curl so that it is above that view, and remove the other view from its superview so that the other view behind it will appear. Then, also set userInteractionEnabled to NO on the XBCurlView instance to allow the user to interact with the view behind it. Lastly, you have to call startAnimating on the XBCurlView instance for it to start rendering the OpenGL ES stuff.

```objective-c
GRect frame = self.view.frame;
double angle = M_PI/2.5;
//Reset cylinder properties, positioning it on the right side, oriented vertically
self.curlView.cylinderPosition = CGPointMake(frame.size.width, frame.size.height/2);
self.curlView.cylinderDirection = CGPointMake(0, 1);
self.curlView.cylinderRadius = 20;
//Update the view drawn on the front of the curling page
[self.curlView drawViewOnFrontOfPage:self.messyView];
//Start the cylinder animation
[self.curlView setCylinderPosition:CGPointMake(frame.size.width/6, frame.size.height/2) animatedWithDuration:kDuration];
[self.curlView setCylinderDirection:CGPointMake(cos(angle), sin(angle)) animatedWithDuration:kDuration];
[self.curlView setCylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration];
//Allow interaction with back view
self.curlView.userInteractionEnabled = NO;
//Setup the view hierarchy properly
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
```

An implementation of this can be found in the helper methods `-[XBCurlView curlView:cylinderPosition:cylinderAngle:cylinderRadius:animatedWithDuration:]` and `-[XBCurlView uncurlAnimatedWithDuration:]`.
### Using XBPageCurlView

XBPageCurlView is a view that has support for dragging the page with the finger like in a book. It controls the cylinder of a XBCurlView instance so that the corner of the page will follow the user's finger. It has a corresponding protocol that tells its delegate whether the user flipped to the next page, cancelled flipping to the next page, flipped to the previous page or cancelled flipping to the previous page. 
