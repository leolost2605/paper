/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.InputHandler : Object {
    public Gtk.Widget target { private get; construct; }
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    private Gtk.GestureStylus stylus_gesture;

    private Gdk.DeviceTool? last_device_tool;

    public InputHandler (Gtk.Widget target, ToolSelection tool_selection, Engine engine) {
        Object (target: target, tool_selection: tool_selection, engine: engine);
    }

    construct {
        stylus_gesture = new Gtk.GestureStylus () {
            stylus_only = false
        };
        stylus_gesture.down.connect (on_down);
        stylus_gesture.motion.connect (on_motion);
        stylus_gesture.up.connect (on_up);
        stylus_gesture.proximity.connect (on_proximity);
        target.add_controller (stylus_gesture);
    }

    private Graphene.Point get_point (double x, double y) {
        return Graphene.Point () {
            x = (float) x,
            y = (float) y
        };
    }

    private void on_down (double x, double y) {
        stylus_gesture.set_state (CLAIMED);
        engine.start_event (get_point (x, y));
    }

    private void on_motion (double x, double y) {
        Gdk.TimeCoord[] time_coords;
        stylus_gesture.get_backlog (out time_coords);

        Graphene.Point[] points = {};
        foreach (var time_coord in time_coords) {
            if (!(Gdk.AxisFlags.X in time_coord.flags && Gdk.AxisFlags.Y in time_coord.flags)) {
                continue;
            }

            points += get_point (time_coord.axes[Gdk.AxisUse.X], time_coord.axes[Gdk.AxisUse.Y]);
        }

        engine.motion_event (get_point (x, y), points);
    }

    private void on_up (double x, double y) {
        engine.commit_event (get_point (x, y));
    }

    private void on_proximity () {
        if (stylus_gesture.get_device_tool () == last_device_tool) {
            return;
        }

        last_device_tool = stylus_gesture.get_device_tool ();

        switch (last_device_tool.tool_type) {
            case PEN:
                tool_selection.select_last_tool_of_type (typeof (Pen));
                break;

            case ERASER:
                tool_selection.select_last_tool_of_type (typeof (Eraser));
                break;

            default:
                break;
        }
    }
}
