# XBPageCurl

XBPageCurl is a free and open-source implementation of a page curl animation/transition for views in iOS that intends to mimic the behavior of the pages in apps like iBooks and GoogleMaps for iOS.

It uses OpenGL ES 2 to draw a deformed mesh of triangles. Conceptually, it projects the vertices of the mesh on a virtual cylinder that touches the view. You can move, rotate and change the radius of the cylinder, with or without animation. This will make the mesh curl around the cylinder. The mesh deformation is performed in a vertex shader which makes it really fast.

![Uncurled](http://xissburg.com/images/Uncurled.png) ![Curled](http://xissburg.com/images/Curled.png)

## Concepts

The concept behind this page curl effect is that of a virtual cylinder that moves on top of the page and everything that is at the right of this cylinder curls around it till the top of the cylinder and then it continues in a horizontal flat plane, hence showing the back of the page. The cylinder can be moved and rotated and its radius can change. The position of the cylinder is actually any point in its axis projected on the xy-plane, hence any point in the same axis results in the same cylinder.
