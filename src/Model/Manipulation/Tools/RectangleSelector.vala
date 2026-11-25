/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.RectangleSelector : Paper.Tool {
    private SelectionManager? selection;

    private Graphene.Point? start_point;
    private Graphene.Point? current_point;

    public override void load (Variant variant) {
        /* We currently don't store anything */
    }

    public override Variant save () {
        /* We currently don't store anything */
        return new Variant.boolean (false);
    }

    public override void activate (Content content) {
        selection = new SelectionManager (content);
    }

    public override void deactivate (Content content) {
        if (selection.active) {
            content.commit_selection ();
        }

        selection = null;
    }

    public override RenderFlags start (Content content, float x, float y) {
        start_point = Graphene.Point () {
            x = x,
            y = y
        };

        if (selection.active && !selection.start (start_point)) {
            content.commit_selection ();
            return STROKES_CHANGED;
        }

        return NONE;
    }

    public override RenderFlags motion (Content content, float x, float y, Graphene.Point[] backlog) {
        current_point = Graphene.Point () {
            x = x,
            y = y
        };

        RenderFlags flags = TOOL_CHANGED;

        if (selection.active) {
            selection.motion (content, current_point);
            flags |= STROKES_CHANGED;
        }

        return flags;
    }

    public override RenderFlags commit (Content content, float x, float y) {
        if (!selection.active) {
            select_items_in_rectangle (content);
        }

        start_point = null;
        current_point = null;

        return TOOL_CHANGED | STROKES_CHANGED;
    }

    private void select_items_in_rectangle (Content content) {
        if (start_point == null || current_point == null) {
            return;
        }

        var rect = get_selection_rectangle ();

        var items = content.get_items_intersecting_rect (rect);

        if (items.is_empty) {
            return;
        }

        content.select_items (items);

        selection.update_bounds ();
    }

    public override void snapshot_transformed (Gtk.Snapshot snapshot) {
        if (selection.active) {
            selection.snapshot (snapshot);
        } else {
            snapshot_selection_rectangle (snapshot);
        }
    }

    private void snapshot_selection_rectangle (Gtk.Snapshot snapshot) {
        if (start_point == null || current_point == null) {
            return;
        }

        var rect = get_selection_rectangle ();

        var path_builder = new Gsk.PathBuilder ();
        path_builder.add_rect (rect);
        var path = path_builder.to_path ();

        var stroke = new Gsk.Stroke (1.0f);
        var color = Gdk.RGBA ();
        color.parse ("blue");

        snapshot.append_stroke (path, stroke, color);
    }

    private Graphene.Rect get_selection_rectangle () {
        if (start_point == null || current_point == null) {
            return Graphene.Rect ();
        }

        return Graphene.Rect () {
            origin = Graphene.Point () {
                x = float.min (start_point.x, current_point.x),
                y = float.min (start_point.y, current_point.y)
            },
            size = Graphene.Size () {
                width = (current_point.x - start_point.x).abs (),
                height = (current_point.y - start_point.y).abs ()
            }
        };
    }
}
