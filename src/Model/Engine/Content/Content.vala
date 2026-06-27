/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

/**
 * This is the facade of the note model.
 */
public class Quicknote.Content : Object {
    public signal void changed ();

    public Database database { get; construct; }

    public string id { get; private set; }

    public ViewMode view_mode { get; private set; }
    public Background background { get; private set; }
    public Pattern pattern { get; private set; }
    public PageFormat page_format { get; private set; }
    public OriginIndicator origin_indicator { get; private set; }

    private ItemStore items;

    public Content (Database database) {
        Object (database: database);
    }

    construct {
        id = database.path;

        view_mode = new InfiniteViewMode ();
        background = new WhiteBackground ();

        pattern = new Pattern (database);
        pattern.notify.connect (emit_changed);

        page_format = new PageFormat ();
        page_format.notify.connect (emit_changed);

        origin_indicator = new OriginIndicator (database);
        origin_indicator.notify.connect (emit_changed);

        items = new ItemStore (database);
    }

    private void emit_changed () {
        changed ();
    }

    public Gee.Collection<Item> get_items_intersecting_rect (Graphene.Rect rect) {
        return items.get_intersecting_rect (rect);
    }

    public void add_item (Item item) {
        items.add (item);
        emit_changed ();
    }

    public void remove_item (Item item) {
        items.remove (item);
        emit_changed ();
    }

    public Gee.List<Page> calculate_pages () {
        var all_items = items.get_all ();
        var full_bounds = get_item_bounds (all_items);
        return page_format.calculate_pages (full_bounds);
    }

    public Graphene.Rect get_item_bounds (Gee.Collection<Item> items) requires (!items.is_empty) {
        Graphene.Rect? bounds = null;
        foreach (var item in items) {
            if (bounds == null) {
                bounds = item.get_bounds ();
            } else {
                bounds = bounds.union (item.get_bounds ());
            }
        }
        return bounds;
    }

    public void select_items (Gee.Collection<Item> to_select) {
        items.select (to_select);
        emit_changed ();
    }

    public void transform_selection (Gsk.Transform transform) {
        items.transform_selection (transform);
        emit_changed ();
    }

    public void commit_selection () {
        items.commit_selection ();
        emit_changed ();
    }
}
