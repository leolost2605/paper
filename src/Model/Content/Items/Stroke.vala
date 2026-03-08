/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Stroke : Item {
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
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        snapshot.append_stroke (path, stroke, color);
    }

    public override Graphene.Rect get_bounds () {
        return bounds;
    }

    public override bool intersects (Line line) {
        return this.line.intersects (line);
    }
}
