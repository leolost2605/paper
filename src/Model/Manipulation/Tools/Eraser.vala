/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Eraser : Quicknote.Tool {
    private Note current_note;
    private Point? last_point;

    public override void start (Note note) {
        current_note = note;
        last_point = null;
    }

    public override void add_point (float x, float y) {
        var point = new Point (x, y);

        if (last_point == null) {
            last_point = point;
            return;
        }

        var points = new Gee.ArrayList<Point> ();
        points.add (last_point);
        points.add (point);

        var line = new Line (points);

        for (int i = current_note.items.size - 1; i >= 0; i--) {
            var item = current_note.items[i];
            if (item.intersects (line)) {
                current_note.items.remove (item);
            }
        }

        last_point = point;
    }

    public override void commit () {
        // Nothing to do
    }
}
