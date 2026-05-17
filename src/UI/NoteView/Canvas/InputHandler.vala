/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.InputHandler : Object {
    public Gtk.Widget target { get; construct; }
    public Viewport viewport { get; construct; }
    public ToolSelection tool_selection { get; construct; }

    public Content? content { get; set; }

    private Tool? current_tool {
        get { return tool_selection.active_tool; }
    }

    private Gtk.GestureStylus stylus_gesture;

    private Gdk.DeviceTool? last_device_tool;

    public InputHandler (Gtk.Widget target, Viewport viewport, ToolSelection tool_selection) {
        Object (target: target, viewport: viewport, tool_selection: tool_selection);
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

    private Graphene.Point transform_point (double x, double y) {
        var transform = viewport.get_transform ().invert ();

        var point = Graphene.Point () {
            x = (float) x,
            y = (float) y
        };

        return transform.transform_point (point);
    }

    private void on_down (double x, double y) {
        stylus_gesture.set_state (CLAIMED);

        var point = transform_point (x, y);
        current_tool?.start (content, point.x, point.y);
    }

    private void on_motion (double x, double y) {
        var transform = viewport.get_transform ().invert ();

        var point = Graphene.Point () {
            x = (float) x,
            y = (float) y
        };

        var note_point = transform.transform_point (point);

        Gdk.TimeCoord[] time_coords;
        stylus_gesture.get_backlog (out time_coords);

        Graphene.Point[] points = {};
        foreach (var time_coord in time_coords) {
            if (!(Gdk.AxisFlags.X in time_coord.flags && Gdk.AxisFlags.Y in time_coord.flags)) {
                continue;
            }

            var coord = Graphene.Point () {
                x = (float) time_coord.axes[Gdk.AxisUse.X],
                y = (float) time_coord.axes[Gdk.AxisUse.Y]
            };

            points += transform.transform_point (coord);
        }

        current_tool?.motion (content, note_point.x, note_point.y, points);
    }

    private void on_up (double x, double y) {
        var point = transform_point (x, y);
        current_tool?.commit (content, point.x, point.y);
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
