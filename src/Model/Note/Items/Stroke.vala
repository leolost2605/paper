/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Stroke : Item {
    public Line line { get; construct; }
    public float width { get; construct; }
    public Gdk.RGBA color { get; construct; }

    private Gsk.Stroke stroke;

    public Stroke (Line line, float width, Gdk.RGBA color) {
        Object (line: line, width: width, color: color);
    }

    construct {
        stroke = new Gsk.Stroke (width);
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var path_builder = new Gsk.PathBuilder ();

        bool first = true;
        foreach (var point in line.points) {
            if (first) {
                path_builder.move_to (point.x, point.y);
                first = false;
            } else {
                path_builder.line_to (point.x, point.y);
            }
        }

        snapshot.append_stroke (path_builder.to_path (), stroke, color);
    }

    public override bool intersects (Line line) {
        return this.line.intersects (line);
    }
}
