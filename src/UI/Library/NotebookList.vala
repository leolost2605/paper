/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.NotebookList : Granite.Bin {
    public ListModel notebooks { get; construct; }

    private Gtk.MultiSelection selection_model;

    public NotebookList (ListModel notebooks) {
        Object (notebooks: notebooks);
    }

    construct {
        selection_model = new Gtk.MultiSelection (notebooks);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (on_setup);
        factory.bind.connect (on_bind);

        var list_view = new Gtk.ListView (selection_model, factory) {
            single_click_activate = true,
        };
        list_view.activate.connect (on_activate);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            propagate_natural_height = true,
            has_frame = true,
        };

        child = scrolled_window;
    }

    private void on_setup (Object obj) {
        var list_item = (Gtk.ListItem) obj;
        list_item.child = new NotebookListItem (selection_model, list_item);
    }

    private void on_bind (Object obj) {
        var list_item = (Gtk.ListItem) obj;

        var notebook = (Notebook) list_item.item;
        var notebook_list_item = (NotebookListItem) list_item.child;
        notebook_list_item.notebook = notebook;
    }

    private void on_activate (uint position) {
        var notebook = (Notebook) selection_model.get_item (position);

        activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTEBOOK_ACTION, new Variant.string (notebook.uri));
    }
}
