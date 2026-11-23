/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.UndoStack : Object {
    private class Operation : Object {
        public enum Type {
            ADD,
            REMOVE
        }

        public Type operation_type { get; construct; }
        public Item item { get; construct; }

        public Operation (Type type, Item item) {
            Object (operation_type: type, item: item);
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
        iterator = null;

        stack.add (new Operation (ADD, item));

        notify_property ("can-undo");
        notify_property ("can-redo");
    }

    public void notify_item_removed (Item item) {
        iterator = null;

        stack.add (new Operation (REMOVE, item));

        notify_property ("can-undo");
        notify_property ("can-redo");
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
        switch (op.operation_type) {
            case ADD:
                store.remove (op.item);
                break;
            case REMOVE:
                store.add (op.item);
                break;
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
        switch (op.operation_type) {
            case ADD:
                store.add (op.item);
                break;
            case REMOVE:
                store.remove (op.item);
                break;
        }
    }
}
