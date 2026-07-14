/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.Renderer : Object {
    private const RenderFlags TOOL_CHANGED_MASK = TOOL_CHANGED;
    private const RenderFlags CONTENT_CHANGED_MASK = ZOOM_CHANGED | TRANSLATION_CHANGED | STROKES_CHANGED;

    private RenderNodeCache cache;
    private ItemRenderer item_renderer;

    private Gsk.RenderNode? content_node;
    private Gsk.RenderNode? tool_node;

    construct {
        cache = new RenderNodeCache ();
        item_renderer = new ItemRenderer ();
    }

    public void snapshot (Content content, Viewport viewport, Gtk.Snapshot snapshot, Graphene.Rect bounds, RenderFlags flags) {
        if (content_node == null || ((flags & CONTENT_CHANGED_MASK) != 0)) {
            content_node = create_content_node (content, viewport, bounds);
        }

        snapshot.append_node (content_node);
    }

    private Gsk.RenderNode create_content_node (Content content, Viewport viewport, Graphene.Rect bounds) {
        var transform = viewport.get_transform ();
        var scale = viewport.zoom;

        var snapshot = new Gtk.Snapshot ();
        snapshot.save ();
        snapshot.transform (transform);

        var transformed_bounds = transform.invert ().transform_bounds (bounds);

        content.view_mode.push_clip (snapshot, transformed_bounds, content.page_format);
        content.background.snapshot (snapshot, transformed_bounds);

        content.pattern.snapshot (snapshot, transformed_bounds);
        content.page_format.snapshot (snapshot, transformed_bounds);
        content.origin_indicator.snapshot (snapshot, transformed_bounds);

        foreach (var item in content.get_items_intersecting_rect (transformed_bounds)) {
            snapshot_item (snapshot, item, scale);
        }

        content.view_mode.pop_clip (snapshot);

        snapshot.restore ();

        return snapshot.free_to_node ();
    }

    public void snapshot_page (Content content, Gtk.Snapshot snapshot, Page page) {
        var transform = page.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        snapshot.push_clip (page.bounds);

        content.background.snapshot (snapshot, page.bounds);
        content.pattern.snapshot (snapshot, page.bounds);
        content.page_format.snapshot (snapshot, page.bounds);

        foreach (var item in content.get_items_intersecting_rect (page.bounds)) {
            snapshot_item (snapshot, item, 1.0f);
        }

        snapshot.pop (); /* clip page.bounds */

        snapshot.restore ();
    }

    private void snapshot_item (Gtk.Snapshot snapshot, Item item, float scale) {
        var item_bounds = item.get_bounds ();

        if (((int) (item_bounds.size.width * scale)) == 0 || ((int) (item_bounds.size.height * scale)) == 0) {
            return;
        }

        if (!cache.has_node (item, scale)) {
            var node = item_renderer.render_item (item, scale);
            cache.cache_node (item, scale, node);
        }

        snapshot.append_node (cache.get_node (item, scale));
    }

    // Currently completely separate from the content methods but we might want to optimize some stuff here
    // so we go already via the renderer
    public void snapshot_tool (Tool tool, Viewport viewport, Gtk.Snapshot snapshot, RenderFlags flags) {
        if (tool_node == null || ((flags & TOOL_CHANGED_MASK) != 0)) {
            tool_node = create_tool_node (tool, viewport);
        }

        if (tool_node == null) {
            return;
        }

        snapshot.append_node (tool_node);
    }

    private Gsk.RenderNode? create_tool_node (Tool tool, Viewport viewport) {
        var snapshot = new Gtk.Snapshot ();

        var transform = viewport.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        tool.snapshot_transformed (snapshot);

        snapshot.restore ();

        return snapshot.free_to_node ();
    }
}
