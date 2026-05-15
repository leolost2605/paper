/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Renderer : Object {
    private HashTable<Item, Gsk.RenderNode> render_nodes;

    construct {
        render_nodes = new HashTable<Item, Gsk.RenderNode> (null, null);
    }

    public void snapshot (Content content, Viewport viewport, Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        var transform = viewport.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        var transformed_bounds = transform.invert ().transform_bounds (bounds);

        content.view_mode.push_clip (snapshot, transformed_bounds, content.page_format);
        content.background.snapshot (snapshot, transformed_bounds);

        content.pattern.snapshot (snapshot, transformed_bounds);
        content.page_format.snapshot (snapshot, transformed_bounds);

        foreach (var item in content.get_items_intersecting_rect (transformed_bounds)) {
            snapshot_item (snapshot, item);
        }

        content.view_mode.pop_clip (snapshot);

        snapshot.restore ();
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
            snapshot_item (snapshot, item);
        }

        snapshot.pop (); /* page.bounds */

        snapshot.restore ();
    }

    private void snapshot_item (Gtk.Snapshot snapshot, Item item) {
        if (!render_nodes.contains (item)) {
            render_nodes[item] = create_render_node_for_item (item);
        }

        snapshot.append_node (render_nodes[item]);
    }

    private Gsk.RenderNode create_render_node_for_item (Item item) {
        var snapshot = new Gtk.Snapshot ();
        item.snapshot (snapshot);
        return snapshot.to_node ();
    }
}
