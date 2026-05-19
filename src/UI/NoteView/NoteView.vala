/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NoteView : Adw.NavigationPage {
    public const string ACTION_GROUP_PREFIX = "note-view";
    public const string ACTION_PREFIX = "note-view.";
    public const string SHOW_NOTESLIST_ACTION = "show-notes-list";
    public const string EXPORT_PDF_ACTION = "export-pdf";
    public const string OPEN_PROPERTIES_ACTION = "open-properties";

    public Notebook notebook { get; construct; }

    private Note? _current_note;
    public Note? current_note {
        get { return _current_note; }
        set {
            if (_current_note != null) {
                _current_note.close ();
            }

            _current_note = value;

            if (_current_note != null) {
                engine.load_content (_current_note.content);
            }

            export_button.sensitive = _current_note != null;
            properties_button.sensitive = _current_note != null;

            if (_current_note != null) {
                _current_note.open.begin ();
            }
        }
    }

    private ToolStore tool_store;
    private ToolSelection tool_selection;
    private Engine engine;

    private Gtk.MenuButton export_button;
    private Gtk.Button properties_button;
    private DrawingArea drawing_area;

    public NoteView (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        tool_store = new ToolStore ();
        tool_selection = new ToolSelection (tool_store.tools);
        engine = new Engine (tool_selection);

        var toggle_notes_list_button = new Gtk.ToggleButton () {
            icon_name = "folder",
            tooltip_text = _("Toggle notes list"),
            action_name = ACTION_PREFIX + SHOW_NOTESLIST_ACTION
        };
        toggle_notes_list_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var export_menu = new Menu ();
        export_menu.append (_("Export PDF"), ACTION_PREFIX + EXPORT_PDF_ACTION);

        export_button = new Gtk.MenuButton () {
            icon_name = "document-export",
            tooltip_text = _("Export"),
            menu_model = export_menu
        };
        export_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        properties_button = new Gtk.Button () {
            icon_name = "document-properties",
            tooltip_text = _("Properties"),
            action_name = ACTION_PREFIX + OPEN_PROPERTIES_ACTION
        };
        properties_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var header_bar = new Adw.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        header_bar.pack_start (toggle_notes_list_button);
        header_bar.pack_start (export_button);
        header_bar.pack_end (properties_button);

        drawing_area = new DrawingArea (tool_store, tool_selection, engine);

        var notes_list = new NotesList (notebook);
        bind_property ("current-note", notes_list, "selected-note", SYNC_CREATE | BIDIRECTIONAL);

        var content_view = new Adw.ToolbarView () {
            content = drawing_area,
        };
        content_view.add_top_bar (header_bar);
        content_view.add_top_bar (new Gtk.Separator (HORIZONTAL));

        var split_view = new Adw.OverlaySplitView () {
            content = content_view,
            sidebar = notes_list,
            vexpand = true,
        };
        split_view.bind_property ("show-sidebar", header_bar, "show-back-button", SYNC_CREATE | INVERT_BOOLEAN);

        child = split_view;
        notebook.bind_property ("name", this, "title", SYNC_CREATE);

        var show_noteslist_action = new PropertyAction (SHOW_NOTESLIST_ACTION, split_view, "show-sidebar");

        var export_pdf_action = new SimpleAction (EXPORT_PDF_ACTION, null);
        export_pdf_action.activate.connect (on_export_pdf);

        var open_properties_action = new SimpleAction (OPEN_PROPERTIES_ACTION, null);
        open_properties_action.activate.connect (on_open_properties);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (show_noteslist_action);
        action_group.add_action (export_pdf_action);
        action_group.add_action (open_properties_action);
        insert_action_group (ACTION_GROUP_PREFIX, action_group);
    }

    private async void on_export_pdf () {
        if (current_note == null) {
            return;
        }

        try {
            var file = yield select_location (current_note.display_name + ".pdf");
            yield engine.export_pdf (file);
        } catch (Error e) {
            warning ("Failed to export note: %s", e.message);
        }
    }

    private async File? select_location (string initial_name) throws Error {
        var dialog = new Gtk.FileDialog () {
            title = _("Export Note"),
            initial_name = initial_name,
        };

        return yield dialog.save ((Gtk.Window) get_root (), null);
    }

    private void on_open_properties () {
        if (current_note == null || current_note.content == null) {
            return;
        }

        var dialog = new PropertiesDialog (current_note.content) {
            transient_for = (Gtk.Window) get_root (),
        };
        dialog.present ();
    }
}
