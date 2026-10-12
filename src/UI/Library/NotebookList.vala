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

        var factory = new Gtk.BuilderListItemFactory.from_resource (null, "/io/github/leolost2605/paper/ui/notebook-list-item.ui");

        var list_view = new Gtk.ListView (selection_model, factory) {
            single_click_activate = true,
        };
        list_view.add_css_class ("background");
        list_view.activate.connect (on_activate);

        var clamp = new Adw.ClampScrollable () {
            child = list_view,
            maximum_size = 800,
            tightening_threshold = 600,
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = clamp,
            propagate_natural_height = true,
        };

        child = scrolled_window;
    }

    private void on_activate (uint position) {
        var notebook = (Notebook) selection_model.get_item (position);

        activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTEBOOK_ACTION, new Variant.string (notebook.uri));
    }
}
