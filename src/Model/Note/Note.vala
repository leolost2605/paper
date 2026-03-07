/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

/**
 * This is the facade of the note model.
 */
public class Quicknote.Note : Object {
    public Database database { get; construct; }

    public Background background { get; construct set; }

    private ItemStore items;

    public Note (Database database) {
        Object (database: database);
    }

    construct {
        background = new WhiteBackground ();

        items = new ItemStore (database);
    }

    public async void load () throws Error {
        yield database.open ();
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
}
