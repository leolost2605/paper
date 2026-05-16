/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pen : Quicknote.Tool {
    public Gdk.RGBA color { get; set; default = { 0, 0, 0, 1 }; }
    public float width { get; set; default = 2.0f; }

    private Gee.ArrayList<Point>? points;
    private Stroke? current_stroke;

    public override void start (Content content, float x, float y) {
        points = new Gee.ArrayList<Point> ();
    }

    public override void motion (Content content, float x, float y, Graphene.Point[] backlog) {
        foreach (var point in backlog) {
            points.add (new Point (point.x, point.y));
        }

        points.add (new Point (x, y));

        current_stroke = new Stroke (new Line (points.to_array ()), width, color);
    }

    public override void commit (Content content, float x, float y) {
        if (current_stroke != null) {
            content.add_item (current_stroke);
        }

        current_stroke = null;
        points = null;
    }

    public override void snapshot_transformed (Gtk.Snapshot snapshot) {
        if (current_stroke == null) {
            return;
        }

        current_stroke.snapshot (snapshot);
    }
}
