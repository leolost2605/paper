/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NotesListItem : Granite.Bin {
    public Gtk.TreeListRow? row {
        set {
            if (value == null) {
                return;
            }

            expander.list_row = value;

            var file = (FileBase) value.item;

            label.label = file.display_name;
        }
    }

    private Gtk.TreeExpander expander;
    private Gtk.Label label;

    construct {
        label = new Gtk.Label (null) {
            margin_start = 3,
            ellipsize = END
        };

        expander = new Gtk.TreeExpander () {
            child = label,
        };

        child = expander;
    }
}
