/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.RenderNodeCache : Object {
    private HashTable<Item, Gee.HashMap<int, Gsk.RenderNode>> nodes;

    construct {
        nodes = new HashTable<Item, Gee.HashMap<int, Gsk.RenderNode>> (null, null);
    }

    public bool has_node (Item item, float scale) {
        return (item in nodes) && nodes[item].has_key (scale_to_int (scale));
    }

    public Gsk.RenderNode get_node (Item item, float scale) requires (has_node (item, scale)) {
        return nodes[item][scale_to_int (scale)];
    }

    public void cache_node (Item item, float scale, Gsk.RenderNode node) {
        if (!nodes.contains (item)) {
            nodes[item] = new Gee.HashMap<int, Gsk.RenderNode> ();
        }

        nodes[item][scale_to_int (scale)] = node;
    }

    private static int scale_to_int (float scale) {
        return (int) (scale * 10);
    }
}
