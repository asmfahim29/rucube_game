// main.js - three.js cube and Flutter bridge (compatibility-fixed)
// Now supports dynamic NxNxN cube creation via window.createCube(n)
// Camera auto-frames the cube based on N so large cubes (e.g. 10x10) are visible.

(() => {
  // Basic three.js setup (single renderer / scene / camera / controls)
  const canvas = document.getElementById('gl');
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false });

  // color management & tone mapping so hex colors appear correctly
  if (THREE && THREE.sRGBEncoding) {
    renderer.outputEncoding = THREE.sRGBEncoding;
    renderer.toneMapping = THREE.ACESFilmicToneMapping || renderer.toneMapping;
    renderer.toneMappingExposure = 1.0;
    renderer.physicallyCorrectLights = true;
  }

  renderer.setPixelRatio(window.devicePixelRatio || 1);
  renderer.setSize(window.innerWidth, window.innerHeight);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0b0b10);

  const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 1000);
  camera.position.set(4.5, 4.5, 4.5);

  const controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.12;
  controls.enablePan = false;

  // Lighting - stronger ambient and directional so stickers are visible
  const ambient = new THREE.AmbientLight(0xffffff, 0.45);
  scene.add(ambient);
  const hemi = new THREE.HemisphereLight(0xffffff, 0x222222, 0.6);
  scene.add(hemi);
  const dir = new THREE.DirectionalLight(0xffffff, 1.2);
  dir.position.set(5, 10, 7);
  scene.add(dir);

  // Root object for cube (recreated on each build)
  let cubeRoot = new THREE.Object3D();
  scene.add(cubeRoot);

  // Geometries & common materials (kept here to reuse)
  // Note: if you plan to create very large cubes, consider using InstancedMesh to improve performance.
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

  // State for the current cube
  let cubies = []; // { mesh, stickers, pos: {i,j,k} }
  let stickerMeshes = [];
  // offset is how far cubie centers are spaced (kept constant)
  let offset = 1.02;

  // Utility to clear previous cube
  function clearCube() {
    // remove from scene and dispose resources lightly
    try {
      cubeRoot.traverse((c) => {
        if (c.geometry) { c.geometry.dispose && c.geometry.dispose(); }
        if (c.material) {
          if (Array.isArray(c.material)) c.material.forEach(m => m.dispose && m.dispose());
          else c.material.dispose && c.material.dispose();
        }
      });
    } catch (e) {
      // ignore disposal errors
    }
    try { scene.remove(cubeRoot); } catch (e) {}
    cubeRoot = new THREE.Object3D();
    scene.add(cubeRoot);

    cubies = [];
    stickerMeshes = [];
  }

  // Build NxNxN cube. N must be >= 1
  function buildCube(N = 3) {
    if (!Number.isInteger(N) || N < 1) N = 3;
    clearCube();

    // center offset logic: index i=0..N-1 -> coord = (i - (N-1)/2)
    const centerOffset = (N - 1) / 2;

    for (let i = 0; i < N; i++) {
      for (let j = 0; j < N; j++) {
        for (let k = 0; k < N; k++) {
          const cubie = new THREE.Mesh(cubieGeo, coreMat);
          const x = (i - centerOffset) * offset;
          const y = (j - centerOffset) * offset;
          const z = (k - centerOffset) * offset;
          cubie.position.set(x, y, z);
          cubeRoot.add(cubie);

          const stickers = {};
          const addSticker = (name, normal, color) => {
            const mat = new THREE.MeshStandardMaterial({
              color,
              roughness: 0.36,
              metalness: 0.02,
              side: THREE.DoubleSide
            });
            // tiny emissive so colors remain readable under darker lighting
            try {
              const c = new THREE.Color(color);
              mat.emissive = c.clone().multiplyScalar(0.04);
            } catch (e) {}
            const m = new THREE.Mesh(stickerGeo, mat);
            // Position sticker a little out from the cubie face
            m.position.copy(normal).multiplyScalar(0.51);
            const q = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 0, 1), normal);
            m.setRotationFromQuaternion(q);
            m.userData = { stickerName: name };
            cubie.add(m);
            stickerMeshes.push(m);
            stickers[name] = m;
          };

          // Which stickers to add? If at a boundary index
          if (j === N - 1) addSticker('U', new THREE.Vector3(0, 1, 0), COLORS.U);
          if (j === 0) addSticker('D', new THREE.Vector3(0, -1, 0), COLORS.D);
          if (k === N - 1) addSticker('F', new THREE.Vector3(0, 0, 1), COLORS.F);
          if (k === 0) addSticker('B', new THREE.Vector3(0, 0, -1), COLORS.B);
          if (i === 0) addSticker('L', new THREE.Vector3(-1, 0, 0), COLORS.L);
          if (i === N - 1) addSticker('R', new THREE.Vector3(1, 0, 0), COLORS.R);

          cubies.push({ mesh: cubie, stickers, pos: { i, j, k } });
        }
      }
    }
  }

  // Raycaster & pointer helpers (depend on stickerMeshes)
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
    if (hovered && hovered.material && hovered.material.emissive) hovered.material.emissive.setHex(0x000000);
    hovered = stickerMesh;
    if (hovered && hovered.material && hovered.material.emissive) hovered.material.emissive.setHex(0x222222);
  }

  // Interaction state
  let isPointerDown = false;
  let startPoint = null;
  let selected = null;
  let dragging = false;
  const dragThreshold = 6;

  function findLayerCubies(axis, coord) {
    // coord is offset coordinate (e.g., -center..center). We'll compare rounded positions.
    return cubies.filter(c => Math.round(c.mesh.position[axis] / offset) === Math.round(coord));
  }

  function safeAttachToPivot(mesh, pivot) {
    if (typeof pivot.attach === 'function') {
      try { pivot.attach(mesh); return; } catch (e) {}
    }
    if (typeof THREE.SceneUtils === 'object' && typeof THREE.SceneUtils.attach === 'function') {
      try { THREE.SceneUtils.attach(mesh, cubeRoot, pivot); return; } catch (e) {}
    }
    const worldPos = new THREE.Vector3();
    const worldQuat = new THREE.Quaternion();
    const worldScale = new THREE.Vector3();
    mesh.getWorldPosition(worldPos);
    mesh.getWorldQuaternion(worldQuat);
    mesh.getWorldScale(worldScale);
    try { cubeRoot.remove(mesh); } catch (e) {}
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

    layer.forEach(c => safeAttachToPivot(c.mesh, pivot));

    const angle = (Math.PI / 2) * direction * -1;
    if (animate) {
      gsap.to(pivot.rotation, {
        [axis]: pivot.rotation[axis] + angle,
        duration: 0.35,
        ease: "power2.out",
        onComplete: () => {
          layer.forEach(c => {
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

  // Pointer handlers (attached to canvas)
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
    if (dist > dragThreshold) dragging = true;
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

  // Exposed functions
  // createCube will build the cube and auto-adjust camera to frame it.
  window.createCube = function(n) {
    // Accept string/int; clamp to reasonable size (1..30)
    let N = parseInt(n, 10);
    if (Number.isNaN(N) || N < 1) N = 3;
    if (N > 30) {
      console.warn('Requested cube size too large; clamping to 30 for safety.');
      N = 30;
    }
    if (N > 10) {
      console.warn('Large cube requested (', N, '×', N, '×', N, '). This can be slow. Consider using InstancedMesh for better performance.');
    }

    buildCube(N);

    // Auto-frame camera: compute approximate span and move camera back accordingly
    const span = N * offset; // approximate full span across one axis
    // distance factor empirically chosen to frame cube comfortably
    const distance = Math.max(4.5, span * 1.1);
    camera.position.set(distance, distance, distance);
    camera.near = Math.max(0.1, distance / 1000);
    camera.far = Math.max(1000, distance * 20);
    camera.updateProjectionMatrix();

    // Make sure controls target is center
    controls.target.set(0, 0, 0);
    controls.update();

    // If you embed in a smaller viewport, you may need to increase the multiplier above (1.1 -> 1.4)
  };

  window.scramble = function(moves = 12) {
    const axes = [new THREE.Vector3(1,0,0), new THREE.Vector3(0,1,0), new THREE.Vector3(0,0,1)];
    for (let i = 0; i < moves; i++) {
      const a = axes[Math.floor(Math.random() * axes.length)];
      const coordCandidates = cubies.length ?
        Array.from(new Set(cubies.map(c => Math.round(c.mesh.position.x / offset)))) : [-1,0,1];
      const coord = coordCandidates[Math.floor(Math.random() * coordCandidates.length)];
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
        try { sm.material.color.set(colorHex); } catch (e) {}
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

  // Wire UI buttons if present
  try {
    const scrambleBtn = document.getElementById('scramble');
    if (scrambleBtn) scrambleBtn.addEventListener('click', (ev) => { ev.preventDefault(); window.scramble(); });

    const resetBtn = document.getElementById('reset');
    if (resetBtn) resetBtn.addEventListener('click', (ev) => { ev.preventDefault(); window.resetCube(); });

    // size selector + create button (optional in index.html)
    const sizeInput = document.getElementById('cube-size');
    const createBtn = document.getElementById('create-cube');
    if (createBtn && sizeInput) {
      createBtn.addEventListener('click', (ev) => {
        ev.preventDefault();
        const val = parseInt(sizeInput.value || '3', 10) || 3;
        window.createCube(val);
      });
    }
  } catch (e) {}

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

  // Build default cube (3x3)
  window.createCube(3);

  // Initial small animation
  if (typeof gsap !== 'undefined') {
    gsap.from(cubeRoot.rotation, { y: -0.6, duration: 0.8, ease: "power3.out" });
  }

})();