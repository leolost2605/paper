/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Eraser : Quicknote.Tool {
    private Point? last_point;

    public override void start (Content content, float x, float y) {
        // Nothing to do here
    }

    public override void motion (Content content, float x, float y, Graphene.Point[] backlog) {
        var point = new Point (x, y);

        if (last_point == null) {
            last_point = point;
            return;
        }

        var line = new Line ({ point, last_point });

        var hit = content.get_items_intersecting_line (line);

        foreach (var item in hit) {
            content.remove_item (item);
        }

        last_point = point;
    }

    public override void commit (Content content, float x, float y) {
        last_point = null;
    }
}
