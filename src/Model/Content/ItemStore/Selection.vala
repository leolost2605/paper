/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Selection : Object {
    private Gee.HashMap<Item, SelectedItem> selected_items = new Gee.HashMap<Item, SelectedItem> ();

    public void select (Gee.Collection<Item> items) {
        foreach (var item in items) {
            selected_items[item] = new SelectedItem (item, new Gsk.Transform ());
        }
    }

    public void transform (Gsk.Transform transform) {
        var iterator = selected_items.map_iterator ();
        while (iterator.next ()) {
            var val = iterator.get_value ();
            iterator.set_value (new SelectedItem (val.item, val.transform.transform (transform)));
        }
    }

    public Item? get_selected_item (Item item) {
        return selected_items[item];
    }

    public void clear () {
        selected_items.clear ();
    }

    public Gee.Map<Item, SelectedItem> get_selected_items () {
        return selected_items;
    }
}
