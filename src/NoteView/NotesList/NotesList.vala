/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.NotesList : Adw.NavigationPage {
    public Notebook notebook { get; construct; }

    public NoteFile? selected_note { get; set; }

    public NotesList (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        var tree_model = new Gtk.TreeListModel (notebook.root.children, false, false, create_child_model_func);

        var selection_model = new Gtk.SingleSelection (tree_model);
        bind_property (
            "selected-note", selection_model, "selected", SYNC_CREATE | BIDIRECTIONAL,
            (binding, from_val, ref to_val) => {
                var note = (NoteFile?) from_val.get_object ();

                if (note == null) {
                    to_val.set_uint (Gtk.INVALID_LIST_POSITION);
                    return true;
                }

                for (uint i = 0; i < tree_model.n_items; i++) {
                    var row = (Gtk.TreeListRow) tree_model.get_item (i);

                    if (row.item == note) {
                        to_val.set_uint (i);
                        return true;
                    }
                }

                return false;
            }, (binding, from_val, ref to_val) => {
                var index = from_val.get_uint ();

                if (index == Gtk.INVALID_LIST_POSITION) {
                    to_val.set_object (null);
                    return true;
                }

                var row = (Gtk.TreeListRow) tree_model.get_item (index);

                if (row.item is NoteFile) {
                    to_val.set_object ((NoteFile) row.item);
                    return true;
                }

                return false;
            }
        );

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (on_setup);
        factory.bind.connect (on_bind);
        factory.unbind.connect (on_unbind);

        var list_view = new Gtk.ListView (selection_model, factory);
        list_view.add_css_class ("notes-list");

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
        };

        child = scrolled_window;
    }

    private ListModel? create_child_model_func (Object item) {
        var file = (FileBase) item;
        return file.open (null)?.children;
    }

    private void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new NotesListItem ();
    }

    private void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var tree_row = (Gtk.TreeListRow) item.item;

        var file = (FileBase) tree_row.item;
        file.load ();

        var notes_list_item = (NotesListItem) item.child;
        notes_list_item.row = tree_row;
    }

    private void on_unbind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var tree_row = (Gtk.TreeListRow) item.item;

        var file = (FileBase) tree_row.item;
        file.queue_unload ();

        var notes_list_item = (NotesListItem) item.child;
        notes_list_item.row = null;
    }
}
