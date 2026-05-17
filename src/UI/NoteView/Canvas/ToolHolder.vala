/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.ToolHolder : Granite.Bin {
    public ToolSelection tool_selection { get; construct; }
    public Viewport viewport { get; construct; }

    public Content? content { get; set; }

    private Tool? current_tool {
        get { return tool_selection.active_tool; }
    }

    private Gtk.GestureStylus stylus_gesture;

    private Gdk.DeviceTool? last_device_tool;

    public ToolHolder (ToolSelection tool_selection, Viewport viewport) {
        Object (tool_selection: tool_selection, viewport: viewport);
    }

    construct {
        stylus_gesture = new Gtk.GestureStylus () {
            stylus_only = false
        };
        stylus_gesture.down.connect (on_down);
        stylus_gesture.motion.connect (on_motion);
        stylus_gesture.up.connect (on_up);
        stylus_gesture.proximity.connect (on_proximity);
        add_controller (stylus_gesture);
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

        queue_draw ();
    }

    private void on_up (double x, double y) {
        var point = transform_point (x, y);
        current_tool?.commit (content, point.x, point.y);

        queue_draw ();
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

    public override void snapshot (Gtk.Snapshot snapshot) {
        if (!stylus_gesture.is_active ()) {
            return;
        }

        var transform = viewport.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        current_tool?.snapshot_transformed (snapshot);

        snapshot.restore ();
    }
}
