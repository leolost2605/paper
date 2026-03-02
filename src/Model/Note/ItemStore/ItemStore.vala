/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Currently just a fancy wrapper around a list but
 * should in the future be implemented as a R-Tree
 */
public class Quicknote.ItemStore : Object {
    private Gee.ArrayList<Item> items;

    construct {
        items = new Gee.ArrayList<Item> ();
    }

    public void add (Item item) {
        items.add (item);
    }

    public void remove (Item item) {
        items.remove (item);
    }

    public Gee.Collection<Item> get_intersecting_rect (Graphene.Rect rect) {
        var result = new Gee.ArrayList<Item> ();

        foreach (var item in items) {
            if (item.get_bounds ().intersection (rect, null)) {
                result.add (item);
            }
        }

        return result;
    }

    public Gee.Collection<Item> get_intersecting_line (Line line) {
        var result = new Gee.ArrayList<Item> ();

        foreach (var item in items) {
            if (item.intersects (line)) {
                result.add (item);
            }
        }

        return result;
    }
}
