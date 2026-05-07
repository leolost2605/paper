/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NotebookListItem : Granite.Bin {
    public Gtk.MultiSelection selection { get; construct; }
    public Gtk.ListItem list_item { get; construct; }

    public Notebook? notebook {
        set {
            text_binding?.unbind ();
            text_binding = null;

            if (value == null) {
                return;
            }

            text_binding = value.bind_property ("name", display_item, "text", SYNC_CREATE);

            display_item.description = value.uri;
        }
    }

    private Granite.ListItem display_item;

    private Binding? text_binding;

    public NotebookListItem (Gtk.MultiSelection selection, Gtk.ListItem list_item) {
        Object (selection: selection, list_item: list_item);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Delete"), "todo");
        menu.append (_("Rename"), "todo");

        display_item = new Granite.ListItem () {
            menu_model = menu,
        };

        child = display_item;
    }
}
