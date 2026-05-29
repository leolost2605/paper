/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NotesListItem : Granite.ListItem {
    public Gtk.SingleSelection selection { get; construct; }

    public Gtk.TreeListRow? row {
        private get { return expander.list_row; }
        set {
            if (value == null) {
                return;
            }

            expander.list_row = value;

            var file = (FileBase) value.item;

            label.label = file.display_name;
        }
    }

    public NotesListItem (Gtk.SingleSelection selection) {
        Object (selection: selection);
    }

    private Gtk.TreeExpander expander;
    private Gtk.Label label;

    class construct {
        set_css_name ("noteslistitem");
    }

    construct {
        label = new Gtk.Label (null) {
            margin_start = 3,
            ellipsize = END
        };

        expander = new Gtk.TreeExpander () {
            child = label,
        };

        child = expander;

        var menu = new Menu ();
        menu.append (_("Delete"), NotesList.ACTION_PREFIX + NotesList.DELETE_ACTION);
        menu.append (_("Rename"), NotesList.ACTION_PREFIX + NotesList.RENAME_ACTION);

        menu_model = menu;
        // TODO: Select item on menu popup
    }
}
