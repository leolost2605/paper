/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Renderer : Object {
    public Viewport viewport { get; construct; }
    public ToolStore tool_store { get; construct; }

    public Note? note { get; set; }

    private HashTable<Item, Gsk.RenderNode> render_nodes;

    public Renderer (Viewport viewport, ToolStore tool_store) {
        Object (viewport: viewport, tool_store: tool_store);
    }

    construct {
        render_nodes = new HashTable<Item, Gsk.RenderNode> (null, null);
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (note == null) {
            return;
        }

        var transform = viewport.get_transform ();

        snapshot.save ();
        snapshot.transform (transform);

        var transformed_bounds = transform.invert ().transform_bounds (bounds);

        note.content.background.snapshot (snapshot, transformed_bounds);

        foreach (var item in note.content.get_items_intersecting_rect (transformed_bounds)) {
            snapshot_item (snapshot, item);
        }

        tool_store.active_tool?.snapshot (snapshot);

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
