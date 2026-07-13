/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.Stroke : Item {
    public Line line { get; construct; }
    public float width { get; construct; }
    public Gdk.RGBA color { get; construct; }

    private Gsk.Stroke stroke;
    private Gsk.Path path;
    private Graphene.Rect bounds;

    public Stroke (Line line, float width, Gdk.RGBA color) {
        Object (line: line, width: width, color: color);
    }

    construct {
        stroke = new Gsk.Stroke (width);
        stroke.set_line_join (ROUND);
        stroke.set_line_cap (ROUND);

        path = line.to_path ();
        path.get_bounds (out bounds);

        /* We want the full extents of the rendered stroke to be within
           the bounds so compensate for the width */
        bounds.origin.x -= width;
        bounds.origin.y -= width;
        bounds.size.width += 2 * width;
        bounds.size.height += 2 * width;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        snapshot.append_stroke (path, stroke, color);
    }

    public override void snapshot_selected (Gtk.Snapshot snapshot) {
        this.snapshot (snapshot);

        var selection_stroke = new Gsk.Stroke (width + 2.0f);
        snapshot.append_stroke (path, selection_stroke, SelectedItem.SELECTION_COLOR);
    }

    public override Graphene.Rect get_bounds () {
        return bounds;
    }

    public override bool is_near (Graphene.Point point, float epsilon) {
        return this.line.is_near (point, epsilon);
    }

    public override Item copy_transformed (Gsk.Transform transform) {
        return new Stroke (line.copy_transformed (transform), width, color);
    }
}
