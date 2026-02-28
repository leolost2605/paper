/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NoteView : Adw.NavigationPage {
    public const string ACTION_GROUP_PREFIX = "note-view";
    public const string ACTION_PREFIX = "note-view.";
    public const string SHOW_NOTESLIST_ACTION = "show-notes-list";

    public Notebook notebook { get; construct; }

    private Canvas canvas;

    public NoteView (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        var toggle_notes_list_button = new Gtk.ToggleButton () {
            icon_name = "folder",
            tooltip_text = _("Toggle notes list"),
            action_name = ACTION_PREFIX + SHOW_NOTESLIST_ACTION
        };

        var header_bar = new Adw.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        header_bar.pack_start (toggle_notes_list_button);

        canvas = new Canvas ();
        canvas.note = new Note ();

        var split_view = new Adw.OverlaySplitView () {
            content = canvas,
            sidebar = new NotesList (notebook),
            vexpand = true,
        };

        var main_box = new Granite.Box (VERTICAL, NONE);
        main_box.append (header_bar);
        main_box.append (new Gtk.Separator (HORIZONTAL));
        main_box.append (split_view);

        child = main_box;

        var show_noteslist_action = new PropertyAction (SHOW_NOTESLIST_ACTION, split_view, "show-sidebar");

        var action_group = new SimpleActionGroup ();
        action_group.add_action (show_noteslist_action);
        insert_action_group (ACTION_GROUP_PREFIX, action_group);
    }
}
