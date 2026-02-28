/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pen : Quicknote.Tool {
    public Gdk.RGBA color { get; set; default = { 0, 0, 0, 1 }; }
    public float width { get; set; default = 2.0f; }

    private Stroke stroke;

    public override void start (Note note) {
        stroke = new Stroke (new Line (new Gee.ArrayList<Point> ()), width, color);

        note.items.add (stroke);
    }

    public override void add_point (float x, float y) {
        stroke.line.points.add (new Point (x, y));
    }

    public override void commit () {
        // Nothing to do
    }
}
