const gapOut = 8;
const gapIn = 4;
const snap = "Ctrl+Alt+Meta+";

function usableArea(w) {
    const a = workspace.clientArea(KWin.MaximizeArea, w);
    return {
        x: a.x + gapOut,
        y: a.y + gapOut,
        w: a.width - 2 * gapOut,
        h: a.height - 2 * gapOut,
    };
}

function prepare(w) {
    if (w.fullScreen) w.fullScreen = false;
    w.setMaximize(false, false);
}

function place(fx, fw, fy = 0, fh = 1) {
    return () => {
        const w = workspace.activeWindow;
        if (!w || !w.normalWindow) return;
        prepare(w);

        const a = usableArea(w);
        let x = a.x + a.w * fx, y = a.y + a.h * fy;
        let width = a.w * fw, height = a.h * fh;

        if (fx > 0) { x += gapIn; width -= gapIn; }
        if (fx + fw < 1) width -= gapIn;
        if (fy > 0) { y += gapIn; height -= gapIn; }
        if (fy + fh < 1) height -= gapIn;

        w.frameGeometry = { x: Math.floor(x), y: Math.floor(y), width: Math.floor(width), height: Math.floor(height) };
    };
}

function grow(d) {
    return () => {
        const w = workspace.activeWindow;
        if (!w || !w.normalWindow) return;
        prepare(w);
        const g = w.frameGeometry;
        w.frameGeometry = { x: g.x - d, y: g.y - d, width: g.width + 2 * d, height: g.height + 2 * d };
    };
}

function onCurrentDesktop(w) {
    return w.onAllDesktops || w.desktops.indexOf(workspace.currentDesktop) !== -1;
}

function cycleApp() {
    const active = workspace.activeWindow;
    if (!active) return;

    const same = workspace.windowList().filter(w =>
        w.normalWindow && !w.minimized && w.resourceClass === active.resourceClass && onCurrentDesktop(w));
    if (same.length < 2) return;

    const next = same[(same.indexOf(active) + 1) % same.length];
    workspace.raiseWindow(next);
    workspace.activeWindow = next;
}

function moveToScreen(dir) {
    return () => {
        const w = workspace.activeWindow;
        if (!w) return;
        const cur = w.output.geometry;
        const cy = cur.y + cur.height / 2;

        let best = null, bestDist = Infinity;
        for (const o of workspace.screens) {
            const dist = (o.geometry.y + o.geometry.height / 2 - cy) * dir;
            if (dist > 0 && dist < bestDist) { best = o; bestDist = dist; }
        }
        if (best) workspace.sendClientToScreen(w, best);
    };
}

const bindings = [
    ["H", "Left half", place(0, 0.5)],
    ["L", "Right half", place(0.5, 0.5)],
    ["J", "Center half", place(0.25, 0.5)],
    ["Return", "Maximize", place(0, 1)],
    ["Space", "Almost maximize", place(0.05, 0.9, 0.05, 0.9)],
    ["K", "Almost maximize (K)", place(0.05, 0.9, 0.05, 0.9)],
    ["N", "Left three quarters", place(0, 0.75)],
    [".", "Right three quarters", place(0.25, 0.75)],
    ["M", "Left two thirds", place(0, 2 / 3)],
    [",", "Right two thirds", place(1 / 3, 2 / 3)],
    ["Y", "Left third", place(0, 1 / 3)],
    ["O", "Right third", place(2 / 3, 1 / 3)],
    ["U", "Left quarter", place(0, 0.25)],
    ["I", "Right quarter", place(0.75, 0.25)],
    ["=", "Grow", grow(30)],
    ["-", "Shrink", grow(-30)],
    ["P", "Cycle app windows", cycleApp],
    ["Up", "Move to screen above", moveToScreen(-1)],
    ["Down", "Move to screen below", moveToScreen(1)],
];

for (const [key, text, action] of bindings) {
    registerShortcut("Rectangle: " + text, "Rectangle: " + text, snap + key, action);
}

const noResize = /^(steam|steam_app_\d+|bg3|gamescope)$/i;

function sizeOnOpen(w) {
    if (!w.managed || !w.normalWindow || w.transient || w.fullScreen || !w.resizeable) return;

    const cls = (w.resourceClass || "").toLowerCase();
    if (!cls || cls.startsWith("kwin") || cls === "org.kde.kwin") return;
    let fw = 0.6, fh = 0.7;
    if (cls === "com.mitchellh.ghostty-float") { fw = 0.5; fh = 0.6; }
    else if (noResize.test(cls)) return;

    const a = workspace.clientArea(KWin.MaximizeArea, w);
    const width = Math.floor(a.width * fw), height = Math.floor(a.height * fh);
    w.frameGeometry = {
        x: Math.floor(a.x + (a.width - width) / 2),
        y: Math.floor(a.y + (a.height - height) / 2),
        width: width,
        height: height,
    };
}

workspace.windowAdded.connect(sizeOnOpen);
