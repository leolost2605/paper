/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.MoveHandler : Object {
    private const double FRICTION = 4.0;

    public Gtk.Widget target { get; construct; }
    public Engine engine { get; construct; }

    private double last_x;
    private double last_y;
    private double last_zoom;

    private KineticScrolling kinetic_x;
    private KineticScrolling kinetic_y;
    private uint tick_id;

    public MoveHandler (Gtk.Widget target, Engine engine) {
        Object (target: target, engine: engine);
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

        var scroll_controller = new Gtk.EventControllerScroll (BOTH_AXES | KINETIC);
        scroll_controller.scroll_begin.connect (stop_kinetic);
        scroll_controller.scroll.connect (on_scroll);
        scroll_controller.decelerate.connect (on_decelerate);

        var zoom_gesture = new Gtk.GestureZoom ();
        zoom_gesture.begin.connect (on_zoom_begin);
        zoom_gesture.scale_changed.connect (on_zoom);

        target.add_controller (drag_gesture);
        target.add_controller (swipe_gesture);
        target.add_controller (scroll_controller);
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

        engine.move_view ((float) delta_x, (float) delta_y);

        last_x = x;
        last_y = y;
    }

    private void on_swipe (double velocity_x, double velocity_y) {
        stop_kinetic ();

        var current_time = target.get_frame_clock ().get_frame_time ();

        kinetic_x = new KineticScrolling (current_time, 0, velocity_x, FRICTION);
        kinetic_y = new KineticScrolling (current_time, 0, velocity_y, FRICTION);

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
            engine.move_view ((float) kinetic_x.delta, 0);

            if (kinetic_x.velocity.abs () < 0.1) {
                kinetic_x = null;
            }
        }

        if (kinetic_y != null) {
            kinetic_y.tick (current_time);
            engine.move_view (0, (float) kinetic_y.delta);

            if (kinetic_y.velocity.abs () < 0.1) {
                kinetic_y = null;
            }
        }

        var should_continue = kinetic_x != null || kinetic_y != null;

        if (!should_continue) {
            tick_id = 0;
        }

        return should_continue ? Source.CONTINUE : Source.REMOVE;
    }

    private bool on_scroll (double delta_x, double delta_y) {
        engine.move_view ((float) (-delta_x), (float) (-delta_y));
        return Gdk.EVENT_STOP;
    }

    private void on_decelerate (double velocity_x, double velocity_y) {
        on_swipe (-velocity_x, -velocity_y);
    }

    private void on_zoom_begin (Gtk.Gesture zoom, Gdk.EventSequence? seq) {
        zoom.set_state (CLAIMED);
        stop_kinetic ();

        last_zoom = 1.0f;
    }

    private void on_zoom (Gtk.GestureZoom zoom, double scale) {
        double center_x, center_y;
        zoom.get_bounding_box_center (out center_x, out center_y);

        var center_point = Graphene.Point () {
            x = (float) center_x,
            y = (float) center_y
        };

        engine.zoom_view ((float) (scale / last_zoom), center_point);

        last_zoom = scale;
    }
}
