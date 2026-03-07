/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Currently just a fancy wrapper around a list but
 * should in the future be implemented as a R-Tree
 */
internal class Quicknote.ItemStore : Object {
    public Database database { get; construct; }

    private HashTable<int, Item> items;
    private HashTable<Item, int> item_ids;

    public ItemStore (Database database) {
        Object (database: database);
    }

    construct {
        items = new HashTable<int, Item> (null, null);
        item_ids = new HashTable<Item, int> (null, null);
    }

    private Item get_item (int id) throws Error {
        if (!(id in items)) {
            cache_item (id, database.get_item (id));
        }

        return items[id];
    }

    private void cache_item (int id, Item item) {
        items[id] = item;
        item_ids[item] = id;
    }

    private void remove_cached_item (int id, Item item) {
        items.remove (id);
        item_ids.remove (item);
    }

    public void add (Item item) {
        try {
            database.add_item (item);
        } catch (Error e) {
            warning ("Failed to add item to database: %s", e.message);
        }
    }

    public void remove (Item item) requires (item in item_ids) {
        var id = item_ids[item];

        remove_cached_item (id, item);

        try {
            database.remove_item (id);
        } catch (Error e) {
            warning ("Failed to remove item from database: %s", e.message);
        }
    }

    public Gee.Collection<Item> get_intersecting_rect (Graphene.Rect rect) {
        var results = new Gee.ArrayList<Item> ();

        try {
            var indeces = database.get_items_intersecting (rect);

            foreach (var index in indeces) {
                results.add (get_item (index));
            }
        } catch (Error e) {
            warning ("Failed to query database for items in bounds: %s", e.message);
        }

        return results;
    }

    public Gee.Collection<Item> get_intersecting_line (Line line) {
        var result = new Gee.ArrayList<Item> ();

        foreach (var item in get_intersecting_rect (line.bounds)) {
            if (item.intersects (line)) {
                result.add (item);
            }
        }

        return result;
    }
}
