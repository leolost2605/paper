/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.Eraser : Paper.Tool {
    public float radius { get; set; default = 4.0f; }

    public override RenderFlags start (Content content, float x, float y) {
        // Nothing to do here
        return NONE;
    }

    public override RenderFlags motion (Content content, float x, float y, Graphene.Point[] backlog) {
        var removed = 0;
        foreach (var point in backlog) {
            removed += remove_close_items (content, point.x, point.y);
        }

        removed += remove_close_items (content, x, y);

        if (removed > 0) {
            return STROKES_CHANGED;
        }

        return NONE;
    }

    private int remove_close_items (Content content, float x, float y) {
        var candidates = get_candidates (content, x, y);
        var point = Graphene.Point ().init (x, y);

        var removed = 0;
        foreach (var candidate in candidates) {
            if (candidate.is_near (point, radius)) {
                content.remove_item (candidate);
                removed++;
            }
        }
        return removed;
    }

    private Gee.Collection<Item> get_candidates (Content content, float x, float y) {
        var bounds = Graphene.Rect ().init (x - radius, y - radius, radius * 2, radius * 2);

        return content.get_items_intersecting_rect (bounds);
    }

    public override RenderFlags commit (Content content, float x, float y) {
        // Nothing to do here
        return NONE;
    }
}
