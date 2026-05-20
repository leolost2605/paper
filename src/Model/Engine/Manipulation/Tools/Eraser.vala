/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Eraser : Quicknote.Tool {
    public float radius { get; set; default = 4.0f; }

    public override void start (Content content, float x, float y) {
        // Nothing to do here
    }

    public override void motion (Content content, float x, float y, Graphene.Point[] backlog) {
        foreach (var point in backlog) {
            remove_close_items (content, point.x, point.y);
        }

        remove_close_items (content, x, y);
    }

    private void remove_close_items (Content content, float x, float y) {
        var candidates = get_candidates (content, x, y);
        var point = Graphene.Point ().init (x, y);

        foreach (var candidate in candidates) {
            if (candidate.is_near (point, radius)) {
                content.remove_item (candidate);
            }
        }
    }

    private Gee.Collection<Item> get_candidates (Content content, float x, float y) {
        var bounds = Graphene.Rect ().init (x - radius, y - radius, radius * 2, radius * 2);

        return content.get_items_intersecting_rect (bounds);
    }

    public override void commit (Content content, float x, float y) {
        // Nothing to do here
    }
}
