/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.RectangleSelector : Quicknote.Tool {
    private SelectionManager? selection;

    private Graphene.Point? start_point;
    private Graphene.Point? current_point;

    public override void start (Content content, float x, float y) {
        start_point = Graphene.Point () {
            x = x,
            y = y
        };

        if (selection != null && !selection.start (start_point)) {
            content.commit_selection ();
            selection = null;
        }
    }

    public override void motion (Content content, float x, float y, Graphene.Point[] backlog) {
        current_point = Graphene.Point () {
            x = x,
            y = y
        };

        if (selection != null) {
            selection.motion (content, current_point);
        }

        changed ();
    }

    public override void commit (Content content, float x, float y) {
        if (selection == null) {
            select_items_in_rectangle (content);
        }

        start_point = null;
        current_point = null;

        changed ();
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

        var bounds = content.get_item_bounds (items);

        selection = new SelectionManager (bounds);
    }

    public override void snapshot_transformed (Gtk.Snapshot snapshot) {
        if (selection == null) {
            snapshot_selection_rectangle (snapshot);
        } else {
            selection.snapshot (snapshot);
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
