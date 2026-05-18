/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Selection : Object {
    private Gee.Set<Item> selection = new Gee.HashSet<Item> ();
    private Gsk.Transform selection_transform = new Gsk.Transform ();

    public void select (Gee.Collection<Item> items) {
        selection.add_all (items);
        selection_transform = new Gsk.Transform ();
    }

    public void transform (Gsk.Transform transform) {
        selection_transform = selection_transform.transform (transform);
    }

    public bool is_item_selected (Item item) {
        return selection.contains (item);
    }

    public Gsk.Transform get_selection_transform () {
        return selection_transform;
    }

    public Gee.Collection<Item> clear_selection () {
        var cleared_items = selection;
        selection = new Gee.HashSet<Item> ();
        selection_transform = new Gsk.Transform ();
        return cleared_items;
    }
}
