/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.NoteView : Adw.NavigationPage {
    public const string ACTION_GROUP_PREFIX = "note-view";
    public const string ACTION_PREFIX = "note-view.";
    public const string SHOW_NOTESLIST_ACTION = "show-notes-list";
    public const string EXPORT_PDF_ACTION = "export-pdf";
    public const string OPEN_PROPERTIES_ACTION = "open-properties";

    public Notebook notebook { get; construct; }

    private static Settings settings;
    private static HashTable<string, string> selected_notes_by_notebook;

    private Note? _current_note;
    private Note? current_note {
        get { return _current_note; }
        set {
            if (_current_note != null) {
                _current_note.close ();
                title_binding.unbind ();
            }

            _current_note = value;

            if (_current_note != null) {
                selected_notes_by_notebook[notebook.uri] = _current_note.uri;
                engine.load_content (_current_note.content);
                _current_note.open.begin ();

                if (_current_note != notes_list.selected_file) {
                    notes_list.selected_file = _current_note;
                }

                title_binding = _current_note.bind_property ("display-name", this, "title", SYNC_CREATE);
            }

            export_button.sensitive = _current_note != null;
            properties_button.sensitive = _current_note != null;
        }
    }

    private ToolStore tool_store;
    private ToolSelection tool_selection;
    private Engine engine;

    private NotesList notes_list;

    private Gtk.MenuButton export_button;
    private Gtk.Button properties_button;
    private DrawingArea drawing_area;

    private Binding? title_binding;

    public NoteView (Notebook notebook) {
        Object (notebook: notebook);
    }

    static construct {
        settings = new Settings ("io.github.leolost2605.paper");
        selected_notes_by_notebook = (HashTable<string, string>) settings.get_value ("selected-notes-by-notebook");
    }

    construct {
        engine = new Engine ();

        tool_store = new ToolStore (notebook.uri);
        tool_selection = new ToolSelection (tool_store.tools);
        tool_selection.notify["active-tool"].connect (() => engine.load_tool (tool_selection.active_tool));
        engine.load_tool (tool_selection.active_tool);

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
        header_bar.pack_end (properties_button);
        header_bar.pack_end (export_button);

        drawing_area = new DrawingArea (tool_store, tool_selection, engine);

        notes_list = new NotesList (notebook);
        notes_list.notify["selected-file"].connect (on_selected_file_changed);

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
        title = _("No open note");

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

        open_last_note.begin ();
    }

    private void on_selected_file_changed (Object obj, ParamSpec pspec) {
        var notes_list = (NotesList) obj;

        if (!(notes_list.selected_file is Note)) {
            return;
        }

        current_note = (Note) notes_list.selected_file;
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

    private async void open_last_note () {
        if (!selected_notes_by_notebook.contains (notebook.uri)) {
            return;
        }

        var uri = selected_notes_by_notebook[notebook.uri];

        var note = yield FileBase.get_for_uri (uri);

        if (note is Note) {
            current_note = (Note) note;
        }
    }
}
