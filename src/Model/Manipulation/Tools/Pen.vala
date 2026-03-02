/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pen : Quicknote.Tool {
    public Gdk.RGBA color { get; set; default = { 0, 0, 0, 1 }; }
    public float width { get; set; default = 2.0f; }

    private Gee.ArrayList<Point>? points;
    private Note? current_note;

    public override void start (Note note) {
        current_note = note;
        points = new Gee.ArrayList<Point> ();
    }

    public override void add_point (float x, float y) {
        points.add (new Point (x, y));

        current_note.current_item = new Stroke (new Line (points.to_array ()), width, color);
    }

    public override void commit () {
        current_note.items.add (current_note.current_item);
        current_note.current_item = null;

        current_note = null;
        points = null;
    }
}
