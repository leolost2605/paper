/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pen : Quicknote.Tool {
    private Stroke stroke;

    public override void start (Note note) {
        var color = Gdk.RGBA ();
        color.parse ("#000000");
        stroke = new Stroke (new Line (new Gee.ArrayList<Point> ()), 2.0f, color);

        note.items.add (stroke);
    }

    public override void add_point (float x, float y) {
        stroke.line.points.add (new Point (x, y));
    }

    public override void commit () {
        // Nothing to do
    }
}
