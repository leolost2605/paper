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

    private bool is_drawing = false;

    construct {
        var controller = new Gtk.EventControllerLegacy ();
        controller.event.connect (on_event);
        add_controller (controller);
    }

    private bool on_event (Gdk.Event event) requires (content != null) {
        switch (event.get_event_type ()) {
            case Gdk.EventType.BUTTON_PRESS:
                is_drawing = true;
                start (content);
                break;

            case Gdk.EventType.BUTTON_RELEASE:
                is_drawing = false;
                commit (content);
                break;

            case Gdk.EventType.MOTION_NOTIFY:
                if (is_drawing) {
                    double surface_x, surface_y;
                    event.get_position (out surface_x, out surface_y);

                    var root = get_root ();
                    double transform_x, transform_y;
                    root.get_surface_transform (out transform_x, out transform_y);

                    var root_point = Graphene.Point () {
                        x = (float) (surface_x - transform_x),
                        y = (float) (surface_y - transform_y),
                    };

                    Graphene.Point widget_point;
                    root.compute_point (this, root_point, out widget_point);

                    var note_point = viewport.get_transform ().invert ().transform_point (widget_point);
                    add_point (content, note_point.x, note_point.y);
                    queue_draw ();
                    return true;
                }

                break;

            default:
                break;
        }

        return false;
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
