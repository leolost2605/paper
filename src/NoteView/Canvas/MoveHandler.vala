/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.MoveHandler : Object {
    private const double FRICTION = 4.0;

    public Gtk.Widget target { get; construct; }
    public Viewport viewport { get; construct; }

    private double last_x;
    private double last_y;
    private double last_zoom;

    private KineticScrolling kinetic_x;
    private KineticScrolling kinetic_y;
    private uint tick_id;

    public MoveHandler (Gtk.Widget target, Viewport viewport) {
        Object (target: target, viewport: viewport);
    }

    construct {
        var drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);

        var swipe_gesture = new Gtk.GestureSwipe () {
            touch_only = true
        };
        swipe_gesture.swipe.connect (on_swipe);
        swipe_gesture.group (drag_gesture);

        var zoom_gesture = new Gtk.GestureZoom ();
        zoom_gesture.begin.connect (on_zoom_begin);
        zoom_gesture.scale_changed.connect (on_zoom);

        target.add_controller (drag_gesture);
        target.add_controller (swipe_gesture);
        target.add_controller (zoom_gesture);
    }

    private void on_drag_begin (Gtk.GestureDrag drag, double x, double y) {
        last_x = 0;
        last_y = 0;
        stop_kinetic ();
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

    private void on_swipe (double velocity_x, double velocity_y) {
        stop_kinetic ();

        var current_time = target.get_frame_clock ().get_frame_time ();

        kinetic_x = new KineticScrolling (current_time, viewport.x, velocity_x, FRICTION);
        kinetic_y = new KineticScrolling (current_time, viewport.y, velocity_y, FRICTION);

        tick_id = target.add_tick_callback (tick_callback);
    }

    private void stop_kinetic () {
        kinetic_x = null;
        kinetic_y = null;

        if (tick_id != 0) {
            target.remove_tick_callback (tick_id);
            tick_id = 0;
        }
    }

    private bool tick_callback () {
        var current_time = target.get_frame_clock ().get_frame_time ();

        if (kinetic_x != null) {
            kinetic_x.tick (current_time);
            viewport.x = (float) kinetic_x.position;

            if (kinetic_x.velocity.abs () < 0.1) {
                kinetic_x = null;
            }
        }

        if (kinetic_y != null) {
            kinetic_y.tick (current_time);
            viewport.y = (float) kinetic_y.position;

            if (kinetic_y.velocity.abs () < 0.1) {
                kinetic_y = null;
            }
        }

        target.queue_draw ();

        var should_continue = kinetic_x != null || kinetic_y != null;

        if (!should_continue) {
            tick_id = 0;
        }

        return should_continue ? Source.CONTINUE : Source.REMOVE;
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
