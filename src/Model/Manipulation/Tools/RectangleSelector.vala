/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.RectangleSelector : Quicknote.Tool {
    private Gee.Collection<Item>? selection;

    private Point? start_point;
    private Point? current_point;

    public override void start (Content content) {
        if (selection != null) {
            foreach (var item in selection) {
                content.remove_item (item);
            }
        }
    }

    public override void add_point (Content content, float x, float y) {
        var point = new Point (x, y);

        if (start_point == null) {
            start_point = point;
        } else {
            current_point = point;
        }
    }

    public override void commit (Content content) {
        if (selection == null) {
            select_items_in_rectangle (content);
        } else {
            move_selection (content);
        }

        start_point = null;
        current_point = null;
    }

    private void select_items_in_rectangle (Content content) {
        if (start_point == null || current_point == null) {
            return;
        }

        var rect = get_selection_rectangle ();

        selection = content.get_items_intersecting_rect (rect);
    }

    private void move_selection (Content content) {
        if (selection == null || start_point == null || current_point == null) {
            return;
        }

        var delta = new Point (current_point.x - start_point.x, current_point.y - start_point.y);

        foreach (var item in selection) {
            content.add_item (item.copy_with_offset (delta));
        }

        selection = null;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        if (selection == null) {
            snapshot_selection_rectangle (snapshot);
        } else {
            snapshot_transformed_selection (snapshot);
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

    private void snapshot_transformed_selection (Gtk.Snapshot snapshot) {
        if (start_point == null || current_point == null || selection == null) {
            return;
        }

        snapshot.save ();
        snapshot.transform (build_transform ());

        foreach (var item in selection) {
            item.snapshot (snapshot);
        }

        snapshot.restore ();
    }

    private Gsk.Transform build_transform () {
        var point = Graphene.Point () {
            x = current_point.x - start_point.x,
            y = current_point.y - start_point.y
        };

        return new Gsk.Transform ().translate (point);
    }
}
