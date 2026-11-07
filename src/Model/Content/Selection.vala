/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.Selection : Object {
    public ItemStore items { private get; construct; }

    private Gee.HashSet<Item> selected_items = new Gee.HashSet<Item> ();
    private Gsk.Transform current_transform;

    public Selection (ItemStore items) {
        Object (items: items);
    }

    construct {
        current_transform = new Gsk.Transform ();
    }

    public void select (Gee.Collection<Item> items) {
        foreach (var item in items) {
            selected_items.add (item);
        }
    }

    public void transform (Gsk.Transform transform) {
        current_transform = current_transform.transform (transform);
    }

    public Gsk.Transform get_current_transform () {
        return current_transform;
    }

    public bool is_item_selected (Item item) {
        return selected_items.contains (item);
    }

    public void commit () {
        foreach (var item in selected_items) {
            items.remove (item);
            items.add (item.copy_transformed (current_transform));
        }

        selected_items.clear ();

        current_transform = new Gsk.Transform ();
    }

    public Gee.Collection<Item> get_selected_items () {
        return selected_items;
    }
}
