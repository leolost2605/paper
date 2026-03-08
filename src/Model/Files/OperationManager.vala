/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.OperationManager : Object {
    public Gtk.SingleSelection selection_model { get; construct; }

    private string? uri_to_select = null;

    public OperationManager (Gtk.SingleSelection selection_model) {
        Object (selection_model: selection_model);
    }

    construct {
        selection_model.items_changed.connect (on_items_changed);
    }

    private void on_items_changed (ListModel model, uint pos, uint removed, uint added) {
        if (uri_to_select == null) {
            return;
        }

        for (uint i = pos; i < pos + added; i++) {
            var row = (Gtk.TreeListRow) model.get_item (i);

            var file_base = (FileBase) row.item;

            if (file_base.uri == uri_to_select) {
                ((Gtk.SingleSelection) model).selected = i;
                uri_to_select = null;
                break;
            }
        }
    }

    public async void create_note (File note) {
        uri_to_select = note.get_uri ();

        try {
            yield note.create_async (NONE, Priority.DEFAULT, null);
        } catch (Error e) {
            warning ("Failed to create new note: %s", e.message);
            uri_to_select = null;
        }
    }

    public async void create_directory (File directory) {
        uri_to_select = directory.get_uri ();

        try {
            yield directory.make_directory_async (Priority.DEFAULT, null);
        } catch (Error e) {
            warning ("Failed to create new directory: %s", e.message);
            uri_to_select = null;
        }
    }
}
