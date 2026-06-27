/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NotesListItem : Granite.Bin {
    public Gtk.SingleSelection selection { get; construct; }

    public Gtk.TreeListRow? row {
        private get { return expander.list_row; }
        set {
            if (value == null) {
                return;
            }

            expander.list_row = value;

            var file = (FileBase) value.item;

            list_item.text = file.display_name;
        }
    }

    private Gtk.TreeExpander expander;
    private Granite.ListItem list_item;

    public NotesListItem (Gtk.SingleSelection selection) {
        Object (selection: selection);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Delete"), NotesList.ACTION_PREFIX + NotesList.DELETE_ACTION);
        menu.append (_("Rename"), NotesList.ACTION_PREFIX + NotesList.RENAME_ACTION);
        // TODO: Select item on menu popup

        list_item = new Granite.ListItem () {
            menu_model = menu,
        };
        ((Gtk.Label) list_item.child.get_first_child ()).ellipsize = END;

        expander = new Gtk.TreeExpander () {
            child = list_item,
        };

        child = expander;
    }
}
