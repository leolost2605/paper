/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Wrapper around the database for caching and some convenience methods.
 */
internal class Quicknote.ItemStore : Object {
    public Database database { get; construct; }

    private HashTable<int, Item> items;
    private HashTable<Item, int> item_ids;

    private Selection selection;

    public ItemStore (Database database) {
        Object (database: database);
    }

    construct {
        items = new HashTable<int, Item> (null, null);
        item_ids = new HashTable<Item, int> (null, null);

        selection = new Selection ();
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
            var id = database.add_item (item);
            cache_item (id, item);
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

    public Gee.Collection<Item> get_all () {
        var results = new Gee.ArrayList<Item> ();

        try {
            var indeces = database.get_all_items ();

            foreach (var index in indeces) {
                results.add (get_item (index));
            }
        } catch (Error e) {
            warning ("Failed to query database for all items: %s", e.message);
        }

        return results;
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

    public void select (Gee.Collection<Item> items) {
        selection.select (items);
    }

    public void transform_selection (Gsk.Transform transform) {
        selection.transform (transform);
    }

    public bool is_selected (Item item) {
        return selection.is_item_selected (item);
    }

    public Gsk.Transform get_selection_transform () {
        return selection.get_selection_transform ();
    }

    public void commit_selection () {
        var transform = get_selection_transform ();
        var items = selection.clear_selection ();
        foreach (var item in items) {
            remove (item);
            add (item.copy_transformed (transform));
        }
    }
}
