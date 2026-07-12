/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.PageFormat : Object {
    public bool active { get; construct set; default = false; }

    public float width { get; construct set; default = 100; }
    public float height { get; construct set; default = 100; }

    private Gsk.Stroke stroke;
    private Gdk.RGBA color;

    construct {
        stroke = new Gsk.Stroke (1.0f);
        color = Gdk.RGBA ();
        color.parse ("grey");
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }

        var n_hidden_vertical_lines = (int) (bounds.origin.x / width);
        var last_hidden_vertical_line_x = n_hidden_vertical_lines * width;
        for (var x = last_hidden_vertical_line_x + width; x < bounds.origin.x + bounds.size.width; x += width) {
            var path_builder = new Gsk.PathBuilder ();
            path_builder.move_to (x, bounds.origin.y);
            path_builder.line_to (x, bounds.origin.y + bounds.size.height);

            var path = path_builder.to_path ();
            snapshot.append_stroke (path, stroke, color);
        }

        var n_hidden_horizontal_lines = (int) (bounds.origin.y / height);
        var last_hidden_horizontal_line_y = n_hidden_horizontal_lines * height;
        for (var y = last_hidden_horizontal_line_y + height; y < bounds.origin.y + bounds.size.height; y += height) {
            var path_builder = new Gsk.PathBuilder ();
            path_builder.move_to (bounds.origin.x, y);
            path_builder.line_to (bounds.origin.x + bounds.size.width, y);

            var path = path_builder.to_path ();
            snapshot.append_stroke (path, stroke, color);
        }
    }

    public Graphene.Size get_size () {
        return Graphene.Size () {
            width = width,
            height = height
        };
    }

    public Gee.List<Page> calculate_pages (Graphene.Rect content_bounds) {
        var pages = new Gee.ArrayList<Page> ();

        if (!active) {
            pages.add (new Page (content_bounds));
            return pages;
        }

        // TODO: This doesn't really work yet
        var top_y = (int) (content_bounds.origin.y / height) - 1;
        var bottom_y = (int) ((content_bounds.origin.y + content_bounds.size.height) / height) + 1;

        var left_x = (int) (content_bounds.origin.x / width) - 1;
        var right_x = (int) ((content_bounds.origin.x + content_bounds.size.width) / width) + 1;

        for (var x = left_x; x <= right_x; x++) {
            for (var y = top_y; y <= bottom_y; y++) {
                var page_bounds = Graphene.Rect () {
                    origin = { x * width, y * height },
                    size = { width, height }
                };
                pages.add (new Page (page_bounds));
            }
        }

        return pages;
    }
}
