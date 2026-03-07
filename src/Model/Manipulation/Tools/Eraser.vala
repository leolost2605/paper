/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Eraser : Quicknote.Tool {
    private Point? last_point;

    public override void start (Note note) {
        // Nothing to do here
    }

    public override void add_point (Note note, float x, float y) {
        var point = new Point (x, y);

        if (last_point == null) {
            last_point = point;
            return;
        }

        var line = new Line ({ point, last_point });

        var hit = note.get_items_intersecting_line (line);

        foreach (var item in hit) {
            note.remove_item (item);
        }

        last_point = point;
    }

    public override void commit (Note note) {
        last_point = null;
    }
}
