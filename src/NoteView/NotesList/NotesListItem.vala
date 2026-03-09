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

            label.label = file.display_name;
        }
    }

    public NotesListItem (Gtk.SingleSelection selection) {
        Object (selection: selection);
    }

    private Gtk.TreeExpander expander;
    private Gtk.Label label;
    private Gtk.PopoverMenu popover_menu;

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

        popover_menu = new Gtk.PopoverMenu.from_model (menu) {
            halign = START,
            has_arrow = false,
            position = BOTTOM,
        };
        popover_menu.set_parent (this);

        var gesture_click = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY,
        };
        gesture_click.released.connect ((n_press, x, y) => popup_menu ((int) x, (int) y));

        var gesture_long_press = new Gtk.GestureLongPress ();
        gesture_long_press.pressed.connect ((x, y) => popup_menu ((int) x, (int) y));

        add_controller (gesture_click);
        add_controller (gesture_long_press);
    }

    ~NotesListItem () {
        popover_menu.unparent ();
    }

    private void popup_menu (int x, int y) {
        selection.selected = row.get_position ();
        popover_menu.pointing_to = {
            x,
            y,
            0,
            0,
        };
        popover_menu.popup ();
    }
}
