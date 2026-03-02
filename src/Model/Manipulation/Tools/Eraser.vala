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

        var line = new Line ({ point, last_point });

        var hit = current_note.items.get_intersecting_line (line);

        foreach (var item in hit) {
            current_note.items.remove (item);
        }

        last_point = point;
    }

    public override void commit () {
        // Nothing to do
    }
}
