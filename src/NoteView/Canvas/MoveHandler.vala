/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.MoveHandler : Object {
    public Gtk.Widget target { get; construct; }
    public Viewport viewport { get; construct; }

    private double last_x;
    private double last_y;
    private double last_zoom;

    public MoveHandler (Gtk.Widget target, Viewport viewport) {
        Object (target: target, viewport: viewport);
    }

    construct {
        var drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);

        var zoom_gesture = new Gtk.GestureZoom ();
        zoom_gesture.begin.connect (on_zoom_begin);
        zoom_gesture.scale_changed.connect (on_zoom);

        target.add_controller (drag_gesture);
        target.add_controller (zoom_gesture);
    }

    private void on_drag_begin (Gtk.GestureDrag drag, double x, double y) {
        last_x = 0;
        last_y = 0;
    }

    private void on_drag_update (Gtk.GestureDrag drag, double x, double y) {
        var delta_x = (x - last_x);
        var delta_y = (y - last_y);

        viewport.x += (float) delta_x;
        viewport.y += (float) delta_y;

        last_x = x;
        last_y = y;

        target.queue_draw ();
    }

    private void on_zoom_begin () {
        last_zoom = 1.0;
    }

    private void on_zoom (Gtk.GestureZoom zoom, double scale) {
        viewport.zoom *= (float) (scale / last_zoom);
        last_zoom = scale;

        // TODO: Keep zoom center centered

        target.queue_draw ();
    }
}
