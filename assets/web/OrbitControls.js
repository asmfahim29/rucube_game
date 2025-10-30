/**
 * OrbitControls.js - non-module UMD build for inclusion as a plain <script>
 * Compatible with THREE r0.156-style builds (global THREE object).
 *
 * Place this file in your assets/web/ folder and load it from your local cube.html:
 *   <script src="three.min.js"></script>
 *   <script src="OrbitControls.js"></script>
 *
 * This file exports THREE.OrbitControls on the global THREE object and does NOT
 * use ES module syntax, which makes it safe for older Android WebViews.
 *
 * The implementation below is the classic OrbitControls (adapted to avoid
 * very-new syntax so it works in older WebView JS engines).
 *
 * Source reference: adapted from three.js examples/js/controls/OrbitControls.js
 * (trimmed/adjusted for compatibility).
 */

(function () {

  // Ensure THREE exists
  if (typeof THREE === 'undefined') {
    console.error('OrbitControls requires THREE to be loaded first.');
    return;
  }

  var OrbitControls = function ( object, domElement ) {

    this.object = object;
    this.domElement = ( domElement !== undefined ) ? domElement : document;

    // API
    this.enabled = true;

    this.target = new THREE.Vector3();

    this.minDistance = 0;
    this.maxDistance = Infinity;

    this.minZoom = 0;
    this.maxZoom = Infinity;

    this.minPolarAngle = 0; // radians
    this.maxPolarAngle = Math.PI; // radians

    this.minAzimuthAngle = - Infinity; // radians
    this.maxAzimuthAngle = Infinity; // radians

    this.enableDamping = false;
    this.dampingFactor = 0.05;

    this.enableZoom = true;
    this.zoomSpeed = 1.0;

    this.enableRotate = true;
    this.rotateSpeed = 1.0;

    this.enablePan = true;
    this.panSpeed = 1.0;
    this.screenSpacePanning = false; // if true, pan in screen-space
    this.keyPanSpeed = 7.0;	// pixels moved per arrow key push

    this.autoRotate = false;
    this.autoRotateSpeed = 2.0; // 30 seconds per orbit when fps is 60

    this.keys = { LEFT: 37, UP: 38, RIGHT: 39, BOTTOM: 40 };

    // internals

    var scope = this;

    var EPS = 0.000001;

    // current position in spherical coordinates
    var spherical = new THREE.Spherical();
    var sphericalDelta = new THREE.Spherical();

    var scale = 1;
    var panOffset = new THREE.Vector3();
    var zoomChanged = false;

    var rotateStart = new THREE.Vector2();
    var rotateEnd = new THREE.Vector2();
    var rotateDelta = new THREE.Vector2();

    var panStart = new THREE.Vector2();
    var panEnd = new THREE.Vector2();
    var panDelta = new THREE.Vector2();

    var dollyStart = new THREE.Vector2();
    var dollyEnd = new THREE.Vector2();
    var dollyDelta = new THREE.Vector2();

    // for reset
    this.target0 = this.target.clone();
    this.position0 = this.object.position.clone();
    this.zoom0 = this.object.zoom !== undefined ? this.object.zoom : 1;

    // events
    var changeEvent = { type: 'change' };
    var startEvent = { type: 'start' };
    var endEvent = { type: 'end' };

    // public methods

    this.getPolarAngle = function () {
      return spherical.phi;
    };

    this.getAzimuthalAngle = function () {
      return spherical.theta;
    };

    this.saveState = function () {
      scope.target0.copy( scope.target );
      scope.position0.copy( scope.object.position );
      scope.zoom0 = scope.object.zoom !== undefined ? scope.object.zoom : 1;
    };

    this.reset = function () {
      scope.target.copy( scope.target0 );
      scope.object.position.copy( scope.position0 );
      if ( scope.object.zoom !== undefined ) scope.object.zoom = scope.zoom0;

      scope.update();

      scope.dispatchEvent( changeEvent );

      state = STATE.NONE;
    };

    // set/get target
    this.setTarget = function (x, y, z) {
      scope.target.set(x, y, z);
    };

    // update - called per frame or after changes
    this.update = function () {

      var offset = new THREE.Vector3();

      // so camera.up is the orbit axis
      var quat = new THREE.Quaternion().setFromUnitVectors( object.up, new THREE.Vector3( 0, 1, 0 ) );
      var quatInverse = quat.clone().invert();

      var lastPosition = new THREE.Vector3();
      lastPosition.copy( object.position );

      var lastQuaternion = new THREE.Quaternion();
      lastQuaternion.copy( object.quaternion );

      // offset
      offset.copy( object.position ).sub( scope.target );

      // rotate offset to "y-axis-is-up" space
      offset.applyQuaternion( quat );

      // convert to spherical coordinates
      spherical.setFromVector3( offset );

      if ( this.autoRotate && state === STATE.NONE ) {
        rotateLeft( getAutoRotationAngle() );
      }

      spherical.theta += sphericalDelta.theta;
      spherical.phi += sphericalDelta.phi;

      // restrict theta and phi
      spherical.theta = Math.max( this.minAzimuthAngle, Math.min( this.maxAzimuthAngle, spherical.theta ) );
      spherical.phi = Math.max( this.minPolarAngle, Math.min( this.maxPolarAngle, spherical.phi ) );

      spherical.makeSafe();

      spherical.radius *= scale;

      // restrict radius
      spherical.radius = Math.max( this.minDistance, Math.min( this.maxDistance, spherical.radius ) );

      // move target by pan offset
      scope.target.add( panOffset );

      offset.setFromSpherical( spherical );

      // rotate offset back to world space
      offset.applyQuaternion( quatInverse );

      object.position.copy( scope.target ).add( offset );

      object.lookAt( scope.target );

      if ( this.enableDamping === true ) {

        sphericalDelta.theta *= ( 1 - this.dampingFactor );
        sphericalDelta.phi *= ( 1 - this.dampingFactor );

      } else {

        sphericalDelta.set( 0, 0, 0 );

      }

      scale = 1;
      panOffset.set( 0, 0, 0 );

      // update condition
      if ( lastPosition.distanceToSquared( object.position ) > EPS || 8 * ( 1 - lastQuaternion.dot( object.quaternion ) ) > EPS ) {

        scope.dispatchEvent( changeEvent );

        lastPosition.copy( object.position );
        lastQuaternion.copy( object.quaternion );

        return true;

      }

      return false;

    };

    // event handlers - mouse / touch / keyboard

    function getAutoRotationAngle() {
      return 2 * Math.PI / 60 / 60 * scope.autoRotateSpeed;
    }

    function getZoomScale() {
      return Math.pow( 0.95, scope.zoomSpeed );
    }

    function rotateLeft( angle ) {
      sphericalDelta.theta -= angle;
    }

    function rotateUp( angle ) {
      sphericalDelta.phi -= angle;
    }

    var panLeft = ( function() {
      var v = new THREE.Vector3();
      return function panLeft ( distance, objectMatrix ) {
        v.setFromMatrixColumn( objectMatrix, 0 ); // get X column of objectMatrix
        v.multiplyScalar( - distance );
        panOffset.add( v );
      };
    }() );

    var panUp = ( function() {
      var v = new THREE.Vector3();
      return function panUp ( distance, objectMatrix ) {
        if ( scope.screenSpacePanning === true ) {
          v.setFromMatrixColumn( objectMatrix, 1 );
        } else {
          v.setFromMatrixColumn( objectMatrix, 0 );
          v.crossVectors( object.up, v );
        }
        v.multiplyScalar( distance );
        panOffset.add( v );
      };
    }() );

    // deltaX and deltaY are in pixels; right and down are positive
    var pan = ( function() {
      var offset = new THREE.Vector3();
      return function pan ( deltaX, deltaY ) {
        var element = scope.domElement === document ? scope.domElement.body : scope.domElement;

        if ( scope.object.isPerspectiveCamera ) {
          // perspective
          var position = scope.object.position;
          offset.copy( position ).sub( scope.target );
          var targetDistance = offset.length();

          // half of the fov is center to top of screen
          targetDistance *= Math.tan( ( scope.object.fov / 2 ) * Math.PI / 180.0 );

          // we use screenWidth, to be consistent with perspective camera
          panLeft( 2 * deltaX * targetDistance / element.clientHeight, scope.object.matrix );
          panUp( 2 * deltaY * targetDistance / element.clientHeight, scope.object.matrix );

        } else if ( scope.object.isOrthographicCamera ) {
          // orthographic
          panLeft( deltaX * ( scope.object.right - scope.object.left ) / scope.object.zoom / element.clientWidth, scope.object.matrix );
          panUp( deltaY * ( scope.object.top - scope.object.bottom ) / scope.object.zoom / element.clientHeight, scope.object.matrix );

        } else {
          // camera neither orthographic nor perspective
          console.warn( 'WARNING: OrbitControls.js encountered an unknown camera type - pan disabled.' );
          scope.enablePan = false;
        }
      };
    }() );

    function dollyIn( dollyScale ) {
      if ( scope.object.isPerspectiveCamera ) {
        scale /= dollyScale;
      } else if ( scope.object.isOrthographicCamera ) {
        scope.object.zoom = Math.max( scope.minZoom, Math.min( scope.maxZoom, scope.object.zoom * dollyScale ) );
        scope.object.updateProjectionMatrix();
        zoomChanged = true;
      } else {
        console.warn( 'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.' );
        scope.enableZoom = false;
      }
    }

    function dollyOut( dollyScale ) {
      if ( scope.object.isPerspectiveCamera ) {
        scale *= dollyScale;
      } else if ( scope.object.isOrthographicCamera ) {
        scope.object.zoom = Math.max( scope.minZoom, Math.min( scope.maxZoom, scope.object.zoom / dollyScale ) );
        scope.object.updateProjectionMatrix();
        zoomChanged = true;
      } else {
        console.warn( 'WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled.' );
        scope.enableZoom = false;
      }
    }

    // mouse events

    var STATE = { NONE: -1, ROTATE: 0, DOLLY: 1, PAN: 2, TOUCH_ROTATE: 3, TOUCH_DOLLY_PAN: 4 };

    var state = STATE.NONE;

    function onMouseDown( event ) {

      if ( scope.enabled === false ) return;

      event.preventDefault();

      if ( event.button === 0 ) {

        if ( scope.enableRotate === false ) return;

        handleMouseDownRotate( event );

        state = STATE.ROTATE;

      } else if ( event.button === 1 ) {

        if ( scope.enableZoom === false ) return;

        handleMouseDownDolly( event );

        state = STATE.DOLLY;

      } else if ( event.button === 2 ) {

        if ( scope.enablePan === false ) return;

        handleMouseDownPan( event );

        state = STATE.PAN;

      }

      if ( state !== STATE.NONE ) {

        scope.domElement.ownerDocument.addEventListener( 'mousemove', onMouseMove, false );
        scope.domElement.ownerDocument.addEventListener( 'mouseup', onMouseUp, false );

        scope.dispatchEvent( startEvent );

      }

    }

    function onMouseMove( event ) {

      if ( scope.enabled === false ) return;

      event.preventDefault();

      if ( state === STATE.ROTATE ) {

        if ( scope.enableRotate === false ) return;

        handleMouseMoveRotate( event );

      } else if ( state === STATE.DOLLY ) {

        if ( scope.enableZoom === false ) return;

        handleMouseMoveDolly( event );

      } else if ( state === STATE.PAN ) {

        if ( scope.enablePan === false ) return;

        handleMouseMovePan( event );

      }

    }

    function onMouseUp( event ) {

      if ( scope.enabled === false ) return;

      scope.domElement.ownerDocument.removeEventListener( 'mousemove', onMouseMove, false );
      scope.domElement.ownerDocument.removeEventListener( 'mouseup', onMouseUp, false );

      scope.dispatchEvent( endEvent );

      state = STATE.NONE;

    }

    function onMouseWheel( event ) {

      if ( scope.enabled === false || scope.enableZoom === false || ( state !== STATE.NONE && state !== STATE.ROTATE ) ) return;

      event.preventDefault();
      event.stopPropagation();

      handleMouseWheel( event );

      scope.dispatchEvent( startEvent ); // not sure if start/end should be fired here...
      scope.dispatchEvent( endEvent );

    }

    // touch events

    function onTouchStart( event ) {

      if ( scope.enabled === false ) return;

      switch ( event.touches.length ) {

        case 1:	// one-fingered touch: rotate
          if ( scope.enableRotate === false ) return;
          handleTouchStartRotate( event );
          state = STATE.TOUCH_ROTATE;
          break;

        case 2:	// two-fingered touch: dolly/pan
          if ( scope.enableZoom === false && scope.enablePan === false ) return;
          handleTouchStartDollyPan( event );
          state = STATE.TOUCH_DOLLY_PAN;
          break;

        default:
          state = STATE.NONE;

      }

      if ( state !== STATE.NONE ) {
        scope.dispatchEvent( startEvent );
      }

    }

    function onTouchMove( event ) {

      if ( scope.enabled === false ) return;

      switch ( event.touches.length ) {

        case 1: // one-fingered touch: rotate
          if ( scope.enableRotate === false ) return;
          if ( state !== STATE.TOUCH_ROTATE ) return; // might be other touch action
          handleTouchMoveRotate( event );
          break;

        case 2: // two-fingered touch: dolly/pan
          if ( scope.enableZoom === false && scope.enablePan === false ) return;
          if ( state !== STATE.TOUCH_DOLLY_PAN ) return;
          handleTouchMoveDollyPan( event );
          break;

        default:
          state = STATE.NONE;

      }

    }

    function onTouchEnd( event ) {

      if ( scope.enabled === false ) return;

      scope.dispatchEvent( endEvent );

      state = STATE.NONE;

    }

    // handlers for different inputs

    function handleMouseDownRotate( event ) {
      rotateStart.set( event.clientX, event.clientY );
    }

    function handleMouseDownDolly( event ) {
      dollyStart.set( event.clientX, event.clientY );
    }

    function handleMouseDownPan( event ) {
      panStart.set( event.clientX, event.clientY );
    }

    function handleMouseMoveRotate( event ) {
      rotateEnd.set( event.clientX, event.clientY );
      rotateDelta.subVectors( rotateEnd, rotateStart );

      var element = scope.domElement === document ? scope.domElement.body : scope.domElement;

      // rotating across whole screen goes 360 degrees around
      rotateLeft( 2 * Math.PI * rotateDelta.x / element.clientWidth * scope.rotateSpeed );

      // rotating up and down along whole screen attempts to go 360, but limited by polar angles
      rotateUp( 2 * Math.PI * rotateDelta.y / element.clientHeight * scope.rotateSpeed );

      rotateStart.copy( rotateEnd );

      scope.update();
    }

    function handleMouseMoveDolly( event ) {
      dollyEnd.set( event.clientX, event.clientY );
      dollyDelta.subVectors( dollyEnd, dollyStart );

      if ( dollyDelta.y > 0 ) {
        dollyIn( getZoomScale() );
      } else if ( dollyDelta.y < 0 ) {
        dollyOut( getZoomScale() );
      }

      dollyStart.copy( dollyEnd );

      scope.update();
    }

    function handleMouseMovePan( event ) {
      panEnd.set( event.clientX, event.clientY );
      panDelta.subVectors( panEnd, panStart );

      pan( panDelta.x, panDelta.y );

      panStart.copy( panEnd );

      scope.update();
    }

    function handleMouseWheel( event ) {
      if ( event.deltaY < 0 ) {
        dollyOut( getZoomScale() );
      } else if ( event.deltaY > 0 ) {
        dollyIn( getZoomScale() );
      }

      scope.update();
    }

    function handleTouchStartRotate( event ) {
      var touch = event.touches[ 0 ];
      rotateStart.set( touch.pageX, touch.pageY );
    }

    function handleTouchStartDollyPan( event ) {
      var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
      var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;

      var distance = Math.sqrt( dx * dx + dy * dy );
      dollyStart.set( 0, distance );

      var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
      var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );
      panStart.set( x, y );
    }

    function handleTouchMoveRotate( event ) {
      var touch = event.touches[ 0 ];
      rotateEnd.set( touch.pageX, touch.pageY );
      rotateDelta.subVectors( rotateEnd, rotateStart );

      var element = scope.domElement === document ? scope.domElement.body : scope.domElement;
      rotateLeft( 2 * Math.PI * rotateDelta.x / element.clientWidth * scope.rotateSpeed );
      rotateUp( 2 * Math.PI * rotateDelta.y / element.clientHeight * scope.rotateSpeed );

      rotateStart.copy( rotateEnd );

      scope.update();
    }

    function handleTouchMoveDollyPan( event ) {
      if ( event.touches.length < 2 ) return;

      var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
      var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;
      var distance = Math.sqrt( dx * dx + dy * dy );

      dollyEnd.set( 0, distance );
      dollyDelta.subVectors( dollyEnd, dollyStart );

      if ( dollyDelta.y > 0 ) {
        dollyIn( getZoomScale() );
      } else if ( dollyDelta.y < 0 ) {
        dollyOut( getZoomScale() );
      }

      dollyStart.copy( dollyEnd );

      var x = 0.5 * ( event.touches[ 0 ].pageX + event.touches[ 1 ].pageX );
      var y = 0.5 * ( event.touches[ 0 ].pageY + event.touches[ 1 ].pageY );

      panEnd.set( x, y );
      panDelta.subVectors( panEnd, panStart );

      pan( panDelta.x, panDelta.y );

      panStart.copy( panEnd );

      scope.update();
    }

    function onContextMenu( event ) {
      event.preventDefault();
    }

    // add event listeners

    this.domElement.addEventListener( 'contextmenu', onContextMenu, false );

    this.domElement.addEventListener( 'mousedown', onMouseDown, false );
    this.domElement.addEventListener( 'wheel', onMouseWheel, false );

    // Touch
    this.domElement.addEventListener( 'touchstart', onTouchStart, false );
    this.domElement.addEventListener( 'touchend', onTouchEnd, false );
    this.domElement.addEventListener( 'touchmove', onTouchMove, false );

    // keyboard
    function onKeyDown( event ) {

      if ( scope.enabled === false ) return;

      switch ( event.keyCode ) {

        case scope.keys.UP:
          pan( 0, scope.keyPanSpeed );
          scope.update();
          break;

        case scope.keys.BOTTOM:
          pan( 0, - scope.keyPanSpeed );
          scope.update();
          break;

        case scope.keys.LEFT:
          pan( scope.keyPanSpeed, 0 );
          scope.update();
          break;

        case scope.keys.RIGHT:
          pan( - scope.keyPanSpeed, 0 );
          scope.update();
          break;

      }

    }

    this.domElement.addEventListener( 'keydown', onKeyDown, false );

    // dispose
    this.dispose = function () {

      this.domElement.removeEventListener( 'contextmenu', onContextMenu, false );

      this.domElement.removeEventListener( 'mousedown', onMouseDown, false );
      this.domElement.removeEventListener( 'wheel', onMouseWheel, false );

      this.domElement.removeEventListener( 'touchstart', onTouchStart, false );
      this.domElement.removeEventListener( 'touchend', onTouchEnd, false );
      this.domElement.removeEventListener( 'touchmove', onTouchMove, false );

      this.domElement.removeEventListener( 'keydown', onKeyDown, false );

      // remove document handlers in case they are still attached
      try {
        this.domElement.ownerDocument.removeEventListener( 'mousemove', onMouseMove, false );
        this.domElement.ownerDocument.removeEventListener( 'mouseup', onMouseUp, false );
      } catch (e) {}
    };

    // event dispatcher (simple)
    this.addEventListener = function () {};
    this.removeEventListener = function () {};
    this.dispatchEvent = function ( event ) {
      // very small, only used by our code above
      if ( event && event.type === 'change' ) {
        // no-op here; user can set controls.addEventListener('change', fn) if desired,
        // but this minimal dispatcher does not implement a full EventDispatcher.
      }
    };

  }; // end OrbitControls

  // attach to THREE namespace
  THREE.OrbitControls = OrbitControls;

})();