// main.js - three.js cube and Flutter bridge (compatibility-fixed)
(() => {
  // Basic three.js setup
  const canvas = document.getElementById('gl');
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false });
  renderer.setPixelRatio(window.devicePixelRatio || 1);
  renderer.setSize(window.innerWidth, window.innerHeight);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0b0b10);

  const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 100);
  camera.position.set(4.5, 4.5, 4.5);

  const controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.12;
  controls.enablePan = false;

  // Lighting
  const hemi = new THREE.HemisphereLight(0xffffff, 0x222222, 0.45);
  scene.add(hemi);
  const dir = new THREE.DirectionalLight(0xffffff, 0.9);
  dir.position.set(5, 10, 7);
  scene.add(dir);

  // Root object
  const cubeRoot = new THREE.Object3D();
  scene.add(cubeRoot);

  // Geometries & materials
  const cubieGeo = new THREE.BoxGeometry(0.95, 0.95, 0.95);
  const stickerGeo = new THREE.PlaneGeometry(0.86, 0.86);
  const coreMat = new THREE.MeshStandardMaterial({ color: 0x111214, roughness: 0.6 });

  const COLORS = {
    U: 0xffff00, // yellow
    D: 0xffffff, // white
    F: 0xff0000, // red
    B: 0xff8000, // orange
    L: 0x0000ff, // blue
    R: 0x00ff00, // green
  };

  const cubies = [];
  const stickerMeshes = [];
  const offset = 1.02;

  for (let x = -1; x <= 1; x++) {
    for (let y = -1; y <= 1; y++) {
      for (let z = -1; z <= 1; z++) {
        const cubie = new THREE.Mesh(cubieGeo, coreMat);
        cubie.position.set(x * offset, y * offset, z * offset);
        cubeRoot.add(cubie);

        const stickers = {};
        const addSticker = (name, normal, color) => {
          const mat = new THREE.MeshStandardMaterial({ color, roughness: 0.36, metalness: 0.02 });
          const m = new THREE.Mesh(stickerGeo, mat);
          m.position.copy(normal).multiplyScalar(0.51);
          const q = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 0, 1), normal);
          m.setRotationFromQuaternion(q);
          m.userData = { stickerName: name };
          cubie.add(m);
          stickerMeshes.push(m);
          stickers[name] = m;
        };

        if (y === 1) addSticker('U', new THREE.Vector3(0, 1, 0), COLORS.U);
        if (y === -1) addSticker('D', new THREE.Vector3(0, -1, 0), COLORS.D);
        if (z === 1) addSticker('F', new THREE.Vector3(0, 0, 1), COLORS.F);
        if (z === -1) addSticker('B', new THREE.Vector3(0, 0, -1), COLORS.B);
        if (x === -1) addSticker('L', new THREE.Vector3(-1, 0, 0), COLORS.L);
        if (x === 1) addSticker('R', new THREE.Vector3(1, 0, 0), COLORS.R);

        cubies.push({ mesh: cubie, stickers, pos: { x, y, z } });
      }
    }
  }

  // Raycaster
  const ray = new THREE.Raycaster();
  const pointer = new THREE.Vector2();

  function getIntersects(clientX, clientY) {
    const rect = renderer.domElement.getBoundingClientRect();
    pointer.x = ((clientX - rect.left) / rect.width) * 2 - 1;
    pointer.y = -((clientY - rect.top) / rect.height) * 2 + 1;
    ray.setFromCamera(pointer, camera);
    return ray.intersectObjects(stickerMeshes, false);
  }

  // Hover visual
  let hovered = null;
  function setHover(stickerMesh) {
    if (hovered === stickerMesh) return;
    if (hovered && hovered.material.emissive) hovered.material.emissive.setHex(0x000000);
    hovered = stickerMesh;
    if (hovered && hovered.material.emissive) hovered.material.emissive.setHex(0x222222);
  }

  // Interaction state
  let isPointerDown = false;
  let startPoint = null;
  let selected = null;
  let dragging = false;
  const dragThreshold = 6;

  function findLayerCubies(axis, coord) {
    return cubies.filter(c => Math.round(c.mesh.position[axis] / offset) === Math.round(coord));
  }

  function safeAttachToPivot(mesh, pivot) {
    // Prefer pivot.attach if available (keeps world transforms)
    if (typeof pivot.attach === 'function') {
      try {
        pivot.attach(mesh);
        return;
      } catch (e) {
        // fall through to other methods
      }
    }
    // next try THREE.SceneUtils.attach if present
    if (typeof THREE.SceneUtils === 'object' && typeof THREE.SceneUtils.attach === 'function') {
      try {
        THREE.SceneUtils.attach(mesh, cubeRoot, pivot);
        return;
      } catch (e) {}
    }
    // fallback: preserve world transform manually
    const worldPos = new THREE.Vector3();
    const worldQuat = new THREE.Quaternion();
    const worldScale = new THREE.Vector3();
    mesh.getWorldPosition(worldPos);
    mesh.getWorldQuaternion(worldQuat);
    mesh.getWorldScale(worldScale);

    cubeRoot.remove(mesh);
    pivot.add(mesh);

    mesh.position.copy(worldPos);
    mesh.quaternion.copy(worldQuat);
    mesh.scale.copy(worldScale);
  }

  function rotateLayer(axisVec, coordIndex, direction = 1, animate = true) {
    const axis = Math.abs(axisVec.x) > 0.5 ? 'x' : (Math.abs(axisVec.y) > 0.5 ? 'y' : 'z');
    const layer = findLayerCubies(axis, coordIndex);
    const pivot = new THREE.Object3D();
    cubeRoot.add(pivot);

    layer.forEach(c => {
      safeAttachToPivot(c.mesh, pivot);
    });

    const angle = (Math.PI / 2) * direction * -1;
    if (animate) {
      gsap.to(pivot.rotation, {
        [axis]: pivot.rotation[axis] + angle,
        duration: 0.35,
        ease: "power2.out",
        onComplete: () => {
          layer.forEach(c => {
            // move back to cubeRoot while preserving world transform
            safeAttachToPivot(c.mesh, cubeRoot);
            cubeRoot.add(c.mesh);
            // snap positions & rotations to grid
            c.mesh.position.x = Math.round(c.mesh.position.x / offset) * offset;
            c.mesh.position.y = Math.round(c.mesh.position.y / offset) * offset;
            c.mesh.position.z = Math.round(c.mesh.position.z / offset) * offset;
            c.mesh.rotation.x = Math.round(c.mesh.rotation.x / (Math.PI/2)) * (Math.PI/2);
            c.mesh.rotation.y = Math.round(c.mesh.rotation.y / (Math.PI/2)) * (Math.PI/2);
            c.mesh.rotation.z = Math.round(c.mesh.rotation.z / (Math.PI/2)) * (Math.PI/2);
          });
          try { cubeRoot.remove(pivot); } catch (e) {}
          // notify Flutter that a move completed
          notifyFlutter({ type: 'moveComplete', payload: { axis, coordIndex, direction } });
        }
      });
    } else {
      pivot.rotation[axis] += angle;
      layer.forEach(c => {
        safeAttachToPivot(c.mesh, cubeRoot);
        cubeRoot.add(c.mesh);
      });
      try { cubeRoot.remove(pivot); } catch (e) {}
      notifyFlutter({ type: 'moveComplete', payload: { axis, coordIndex, direction } });
    }
  }

  // Compute rotation axis & sign from drag and sticker normal (simple heuristic)
  function computeRotationFromDrag(startEvent, endEvent, stickerWorldNormal) {
    const dx = endEvent.clientX - startEvent.clientX;
    const dy = endEvent.clientY - startEvent.clientY;
    const horizontal = Math.abs(dx) > Math.abs(dy);
    const n = stickerWorldNormal.clone().round();
    let axisVec = new THREE.Vector3();
    if (Math.abs(n.x) > 0.5) {
      axisVec = horizontal ? new THREE.Vector3(0, 0, 1) : new THREE.Vector3(0, 1, 0);
    } else if (Math.abs(n.y) > 0.5) {
      axisVec = horizontal ? new THREE.Vector3(0, 0, 1) : new THREE.Vector3(1, 0, 0);
    } else {
      axisVec = horizontal ? new THREE.Vector3(0, 1, 0) : new THREE.Vector3(1, 0, 0);
    }
    const primary = horizontal ? dx : -dy;
    const sign = primary > 0 ? 1 : -1;
    return { axisVec, sign };
  }

  function toScreenPosition(vec3) {
    const v = vec3.clone().project(camera);
    return new THREE.Vector2((v.x + 1) * 0.5 * renderer.domElement.width, (-v.y + 1) * 0.5 * renderer.domElement.height);
  }

  // Pointer handlers
  function onPointerDown(e) {
    isPointerDown = true;
    startPoint = { clientX: e.clientX, clientY: e.clientY };
    dragging = false;

    const intersects = getIntersects(e.clientX, e.clientY);
    if (intersects.length) {
      const it = intersects[0];
      const stickerMesh = it.object;
      const worldNormal = new THREE.Vector3(0, 0, 1).applyQuaternion(stickerMesh.getWorldQuaternion(new THREE.Quaternion()));
      selected = { cubieMesh: stickerMesh.parent, stickerMesh, worldNormal, point: it.point };
      if (stickerMesh.material && stickerMesh.material.emissive) stickerMesh.material.emissive.setHex(0x333333);
      controls.enabled = false;
    } else {
      selected = null;
      controls.enabled = true;
    }
  }

  function onPointerMove(e) {
    if (!isPointerDown) {
      const intersects = getIntersects(e.clientX, e.clientY);
      setHover(intersects.length ? intersects[0].object : null);
      return;
    }

    if (!startPoint) return;
    const dist = Math.hypot(e.clientX - startPoint.clientX, e.clientY - startPoint.clientY);
    if (dist > dragThreshold) {
      dragging = true;
    }
  }

  function onPointerUp(e) {
    isPointerDown = false;
    controls.enabled = true;
    if (hovered && hovered.material && hovered.material.emissive) hovered.material.emissive.setHex(0x000000);
    if (selected && selected.stickerMesh && selected.stickerMesh.material && selected.stickerMesh.material.emissive) selected.stickerMesh.material.emissive.setHex(0x000000);

    if (selected && dragging) {
      const result = computeRotationFromDrag(startPoint, e, selected.worldNormal);
      const worldPos = selected.cubieMesh.getWorldPosition(new THREE.Vector3());
      const axis = Math.abs(result.axisVec.x) > 0.5 ? 'x' : (Math.abs(result.axisVec.y) > 0.5 ? 'y' : 'z');
      const coordIndex = Math.round(worldPos[axis] / offset);
      rotateLayer(result.axisVec, coordIndex, result.sign, true);
    }

    selected = null;
    dragging = false;
    startPoint = null;
  }

  renderer.domElement.addEventListener('pointerdown', onPointerDown);
  renderer.domElement.addEventListener('pointermove', onPointerMove);
  renderer.domElement.addEventListener('pointerup', onPointerUp);
  renderer.domElement.addEventListener('pointercancel', onPointerUp);
  renderer.domElement.addEventListener('pointerleave', onPointerUp);

  // Exposed functions for Flutter
  window.scramble = function(moves = 12) {
    const axes = [new THREE.Vector3(1,0,0), new THREE.Vector3(0,1,0), new THREE.Vector3(0,0,1)];
    for (let i = 0; i < moves; i++) {
      const a = axes[Math.floor(Math.random() * axes.length)];
      const coord = [-1,0,1][Math.floor(Math.random()*3)];
      const sign = Math.random() > 0.5 ? 1 : -1;
      rotateLayer(a, coord, sign, false);
    }
    gsap.fromTo(camera.position, { z: camera.position.z + 0.2 }, { z: camera.position.z, duration: 0.6, ease: "elastic.out(1,0.5)" });
  };

  window.resetCube = function() {
    window.location.reload();
  };

  window.setStickerColor = function(face, cx, cy, colorHex) {
    stickerMeshes.forEach(sm => {
      var name = sm.userData && sm.userData.stickerName;
      if (name === face) {
        try {
          sm.material.color.set(colorHex);
        } catch (e) {}
      }
    });
  };

  // Flutter messaging helper
  function notifyFlutter(msgObj) {
    const msg = JSON.stringify(msgObj);
    try {
      if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
        window.flutter_inappwebview.callHandler('onMessage', msg);
      } else if (window.Flutter && typeof window.Flutter.postMessage === 'function') {
        window.Flutter.postMessage(msg);
      } else if (window.parent && typeof window.parent.postMessage === 'function') {
        window.parent.postMessage(msg, '*');
      }
    } catch (e) {
      // silent
    }
  }

  // Render loop
  function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
  }
  animate();

  // Resize handling
  window.addEventListener('resize', () => {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
  });

  // Initial small animation
  if (typeof gsap !== 'undefined') {
    gsap.from(cubeRoot.rotation, { y: -0.6, duration: 0.8, ease: "power3.out" });
  }

})();