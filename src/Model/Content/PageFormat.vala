/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.PageFormat : Object {
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
}
