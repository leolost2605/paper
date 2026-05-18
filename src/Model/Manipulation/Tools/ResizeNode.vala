/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.ResizeNode : Object {
    public enum Position {
        TOP_LEFT,
        TOP_RIGHT,
        BOTTOM_LEFT,
        BOTTOM_RIGHT
    }

    public Position position { get; construct; }

    private int size = 10; // TODO: Scale with zoom level

    private Graphene.Rect bounds;

    public ResizeNode (Position position) {
        Object (position: position);
    }

    public void update_position (Graphene.Rect new_selection_bounds) {
        bounds = Graphene.Rect () {
            size = { size, size }
        };

        switch (position) {
            case TOP_LEFT:
                bounds.origin.x = new_selection_bounds.origin.x - size;
                bounds.origin.y = new_selection_bounds.origin.y - size;
                break;

            case TOP_RIGHT:
                bounds.origin.x = new_selection_bounds.origin.x + new_selection_bounds.size.width;
                bounds.origin.y = new_selection_bounds.origin.y - size;
                break;

            case BOTTOM_LEFT:
                bounds.origin.x = new_selection_bounds.origin.x - size;
                bounds.origin.y = new_selection_bounds.origin.y + new_selection_bounds.size.height;
                break;

            case BOTTOM_RIGHT:
                bounds.origin.x = new_selection_bounds.origin.x + new_selection_bounds.size.width;
                bounds.origin.y = new_selection_bounds.origin.y + new_selection_bounds.size.height;
                break;
        }
    }

    public bool contains (Graphene.Point point) {
        return bounds.contains_point (point);
    }

    public void snapshot (Gtk.Snapshot snapshot) {
        var path_builder = new Gsk.PathBuilder ();
        path_builder.add_rect (bounds);
        var path = path_builder.to_path ();

        var stroke = new Gsk.Stroke (1.0f);
        var color = Gdk.RGBA ();
        color.parse ("blue");

        snapshot.append_stroke (path, stroke, color);
    }
}
