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

    construct {
        var stylus_gesture = new Gtk.GestureStylus () {
            stylus_only = false
        };
        stylus_gesture.down.connect (on_down);
        stylus_gesture.motion.connect (on_motion);
        stylus_gesture.up.connect (on_up);
        add_controller (stylus_gesture);
    }

    private void on_down (double x, double y) {
        start (content);
    }

    private void on_motion (double x, double y) {
        var point = Graphene.Point () {
            x = (float) x,
            y = (float) y
        };

        var note_point = viewport.get_transform ().invert ().transform_point (point);
        add_point (content, note_point.x, note_point.y);
        queue_draw ();
    }

    private void on_up (double x, double y) {
        commit (content);
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

    protected abstract void start (Content content);
    protected abstract void add_point (Content content, float x, float y);
    protected abstract void commit (Content content);
    protected virtual void cancel (Content content) {}
    protected virtual void snapshot_transformed (Gtk.Snapshot snapshot) {}
}
