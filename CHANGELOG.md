# 4.0.0
    - This version upgrades all dependencies to match the latest Dart and Flutter versions, to start addressing bugs, and introduces new features then.
# 3.3.1-beta.4
    - runExpressAfter property to control when the animation queue should run express to the last position
    - shouldAnimateCamera property to prevent Google Map Camera Updates to be handled
    - rippleIdleAfter property to stop ripple animation on static marker (no updates) after timeout
    - Fixing bug when trying to clear the markers
    - Improve Ripple effect during Marker movement.

# 3.2.0
    - onTap() marker function support added
    - Added a flag to control when animate Google Maps Camera.
    - Add extended documentation for Animarker properties
    - Fix: Solve flicking issue when user location is moving fast
    - Fix: Autostart animation when the source of location changes stop.

# 3.2.0-beta.3
    - onTap() marker function support added

# 3.1.3-beta.2
    - Added a flag to control when animate Google Maps Camera.

# 3.1.2-beta.1
    - Add extended documentation for Animarker properties
    - Fix: Solve flicking issue when user location is moving fast
    - Fix: Autostart animation when the source of location changes stop.

# 3.1.1-alpha.2
    - Trying with HTML Markup to resize image

# 3.1.1-alpha.1
    - Minor: GIF image resizing

# 3.1.1+2-alpha

**BREAKING**: The library will use now a better reactive Flutter approach
 - Marker's position animation
 - Multiple markers' animations at the same time
 - Null-safety compatible
 - Ripple effect over marker position
 - Marker's rotation or bearing/heading of direction
 - Multipoint linear animation (*Piecewise Linear Approximation Algorithm*)
 - Support animation curves and duration
 - Widget-based with fully customized behaviors
 - Animation warm-up for improving performance
 - Useful **LocationTween**, **AngleTween** and **PolynomialLocationInterpolator** core logic
 - More test coverage

# 1.0.0

- Remove Google Maps dependencies
- Added multiple markers at same time functionality

# 0.1.2

- Update Google Maps constraints and pull request merging

# 0.1.1+1

- Update metadata plugin information

# 0.1.1

- Added working project example to the GitHub repo. Just add your own **Google Maps Api Key**.

# 0.0.2

- Update with a working example and GIF showing the animation movement

# 0.0.1+3

- Issue setting the Duration interval of interpolation

# 0.0.1+2

- Minor error corrections

# 0.0.1+1

- Interpolation between two position points, including rotation of the marker
- Added examples and better description

# 0.0.1

- Interpolation between two position points, including rotation of the marker

















