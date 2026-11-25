/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.UndoStack : Object {
    private class Operation : Object {
        public Gee.Collection<Item> removed_items { get; construct; }
        public Gee.Collection<Item> added_items { get; construct; }

        public Operation.add (Item item) {
            Object (removed_items: new Gee.ArrayList<Item> (), added_items: new Gee.ArrayList<Item> ());

            added_items.add (item);
        }

        public Operation.remove (Item item) {
            Object (removed_items: new Gee.ArrayList<Item> (), added_items: new Gee.ArrayList<Item> ());

            removed_items.add (item);
        }

        public Operation.selection_committed (Gee.Collection<Item> removed_items, Gee.Collection<Item> added_items) {
            Object (removed_items: removed_items, added_items: added_items);
        }
    }

    public ItemStore store { private get; construct; }

    public bool can_undo {
        get {
            if (iterator != null) {
                return iterator.has_previous ();
            }

            return !stack.is_empty;
        }
    }

    public bool can_redo {
        get {
            return iterator != null;
        }
    }

    private Gee.ArrayList<Operation> stack;

    private Gee.BidirIterator<Operation>? iterator; // Points to the op that was last undone

    public UndoStack (ItemStore store) {
        Object (store: store);
    }

    construct {
        stack = new Gee.ArrayList<Operation> ();
    }

    public void notify_item_added (Item item) {
        clear_ops_above_iterator ();

        stack.add (new Operation.add (item));

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    public void notify_item_removed (Item item) {
        clear_ops_above_iterator ();

        stack.add (new Operation.remove (item));

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    public void notify_selection_committed (Gee.Collection<Item> removed_items, Gee.Collection<Item> added_items) {
        clear_ops_above_iterator ();

        stack.add (new Operation.selection_committed (removed_items, added_items));

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    private void clear_ops_above_iterator () {
        if (iterator == null) {
            return;
        }

        do {
            iterator.remove ();
        } while (iterator.next ());

        iterator = null;
    }

    public void undo () {
        if (stack.is_empty) {
            return;
        }

        if (iterator == null) {
            iterator = stack.bidir_list_iterator ();
            iterator.last ();

            var op = iterator.get ();
            undo_op (op);
        } else if (iterator.previous ()) {
            var op = iterator.get ();
            undo_op (op);
        }

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    private void undo_op (Operation op) {
        foreach (var item in op.removed_items) {
            store.add (item);
        }

        foreach (var item in op.added_items) {
            store.remove (item);
        }
    }

    public void redo () {
        if (iterator == null) {
            return;
        }

        var op = iterator.get ();
        redo_op (op);

        if (!iterator.next ()) {
            iterator = null;
        }

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    private void redo_op (Operation op) {
        foreach (var item in op.removed_items) {
            store.remove (item);
        }

        foreach (var item in op.added_items) {
            store.add (item);
        }
    }
}
