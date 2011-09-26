# XBPageCurl

XBPageCurl is a free and open-source implementation of a page curl animation/transition for views in iOS that intends to mimic the behavior of the pages in apps like iBooks and GoogleMaps for iOS.

It uses OpenGL ES 2 to draw a deformed mesh of triangles. Conceptually, it projects the vertices of the mesh on a virtual cylinder that touches the view. You can move, rotate and change the radius of the cylinder, with or without animation. This will make the mesh curl around the cylinder. The mesh deformation is performed in a vertex shader which makes it really fast.

![Uncurled](http://xissburg.com/images/Uncurled.png) ![Curled](http://xissburg.com/images/Curled.png)

## Concepts

The concept behind this page curl effect is that of a virtual cylinder that moves on top of the page and everything that is at the right of this cylinder curls around it till the top of the cylinder and then it continues in a horizontal flat plane, hence showing the back of the page. The cylinder can be moved and rotated and its radius can change. The position of the cylinder is actually any point in its axis projected on the xy-plane, hence any point in the same axis results in the same cylinder.

## How to use

Basically, XBPageCurl can be used in two different ways. It can be used to curl a view and show another view behind it where the user can interact with its elements and then uncurl the view back, pretty much like in the Google Maps app. It can also be used to flip pages like in iBooks, where the user can drag the border of a page and release to flip it or cancel the flip.

### Using XBCurlView

XBCurlView is a low level class that does the actual work for curling the view. It has methods for drawing views or images in one of its three pages (front and back of the page being curled and the next page) and for controlling the cylinder that moves around on top the curling view. It can be used to curl a view to show another view behind it like in Google Maps, or to do another customized view curl transition.

To use it, you first have to initialize an instance using the initializer that best satisfies your needs. The initWithFrame: initializer is a good start, it will create a grid mesh with a resolution proportional to the frame size, which gives good results for cylinder radius above 20. The initWithFrame:antialiasing: allows you to specify whether you want to switch the Open GL ES Multisampling Antialiasing on to get smoother edges. The initWithFrame:horizontalResolution:verticalResolution:antialiasing allows you to choose the mesh resolution (amount of rows and columns on the grid mesh), which you should try to keep proportional to the frame size in order to get a grid of squares, not rectangles. You should only worry about the mesh resolution if you start to see the edges of the triangles at the curled section of the mesh, which can be smoothed out by increasing the resolution.

After it is initialized, you should draw the view or image you want to curl on it using drawViewOnFrontOfPage: or drawImageOnFrontOfPage:, which draws the view or image in the front of the mesh that will curl (in the near future it will be possible to draw another view on the back of this mesh using the methods drawViewOnBackOfPage: or drawImageOnBackOfPage:) to avoid a glitch. You should also set opaque to NO on the XBCurlView instance in order to see through it on the region that has nothing. Then, whenever you want to curl the view, first draw it again on the front of the page to update the image on the curling mesh,  set the initial cylinder properties, then set the final properties with animation, add the XBCurlView instance as a subview of the superview of the view you are gonna curl so that it is above that view, and remove the other view from its superview so that the other view behind it can appear. Then, also set userInteractionEnabled to NO on the XBCurlView instance to allow the user to interact with the view behind it. Lastly, you have to call startAnimating on the XBCurlView instance for it to start rendering the OpenGL ES stuff.

To curl the view back, just set its cylinder position, orientation and radius back to initial state with animation and for one of them assign a completion block that should add the original view back again, remove the XBCurlView instance from its superview and also call stopAnimating to stop the OpenGL ES rendering loop.


