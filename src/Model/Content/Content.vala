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

    public ViewMode view_mode { get; construct set; }
    public Background background { get; construct set; }
    public Pattern pattern { get; construct set; }
    public PageFormat page_format { get; construct set; }

    private ItemStore items;

    public Content (Database database) {
        Object (database: database);
    }

    construct {
        view_mode = new InfiniteViewMode ();
        background = new WhiteBackground ();

        pattern = new Pattern ();
        pattern.notify.connect (emit_changed);

        page_format = new PageFormat ();
        page_format.notify.connect (emit_changed);

        items = new ItemStore (database);
    }

    private void emit_changed () {
        changed ();
    }

    public Gee.Collection<Item> get_all_items () {
        return items.get_all ();
    }

    public Gee.Collection<Item> get_items_intersecting_rect (Graphene.Rect rect) {
        return items.get_intersecting_rect (rect);
    }

    public Gee.Collection<Item> get_items_intersecting_line (Line line) {
        return items.get_intersecting_line (line);
    }

    public void add_item (Item item) {
        items.add (item);
    }

    public void remove_item (Item item) {
        items.remove (item);
    }

    public Gee.List<Page> calculate_pages () {
        var full_bounds = calculate_full_bounds ();
        return page_format.calculate_pages (full_bounds);
    }

    private Graphene.Rect calculate_full_bounds () {
        var items = get_all_items ();

        Graphene.Rect full_bounds = { { 0, 0 }, { 0, 0} };
        foreach (var item in items) {
            full_bounds = full_bounds.union (item.get_bounds ());
        }

        return full_bounds;
    }
}
