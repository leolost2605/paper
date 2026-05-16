/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * TODO: All of the logic here could also be in tool holder. Reevaluate requirements
 * once selector is implemented.
 */
public abstract class Quicknote.Tool : Gtk.Widget {
    private Content? content;
    private Viewport? viewport;

    private Gtk.GestureStylus stylus_gesture;

    construct {
        stylus_gesture = new Gtk.GestureStylus () {
            stylus_only = false
        };
        stylus_gesture.down.connect (on_down);
        stylus_gesture.motion.connect (on_motion);
        stylus_gesture.up.connect (on_up);
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
        start (content, point.x, point.y);
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

        motion (content, note_point.x, note_point.y, points);

        queue_draw ();
    }

    private void on_up (double x, double y) {
        var point = transform_point (x, y);
        commit (content, point.x, point.y);
    }

    public void activate_tool (Viewport viewport, Content content) {
        this.content = content;
        this.viewport = viewport;

        viewport.notify.connect (queue_draw);
    }

    public void deactivate_tool () {
        cancel (content);

        viewport.notify.disconnect (queue_draw);

        this.content = null;
        this.viewport = null;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var transform = viewport.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        snapshot_transformed (snapshot);

        snapshot.restore ();
    }

    protected abstract void start (Content content, float x, float y);
    protected abstract void motion (Content content, float x, float y, Graphene.Point[] backlog);
    protected abstract void commit (Content content, float x, float y);
    protected virtual void cancel (Content content) {}
    protected virtual void snapshot_transformed (Gtk.Snapshot snapshot) {}
}
