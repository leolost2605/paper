/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/notebook-list.ui")]
public class Paper.NotebookList : Granite.Bin {
    public ListModel notebooks { get; construct; }

    [GtkChild]
    private unowned Gtk.MultiSelection selection_model;

    public NotebookList (ListModel notebooks) {
        Object (notebooks: notebooks);
    }

    [GtkCallback]
    private void on_activate (uint position) {
        var notebook = (Notebook) selection_model.get_item (position);
        activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTEBOOK_ACTION, new Variant.string (notebook.uri));
    }
}
