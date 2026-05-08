/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NoteView : Adw.NavigationPage {
    public const string ACTION_GROUP_PREFIX = "note-view";
    public const string ACTION_PREFIX = "note-view.";
    public const string SHOW_NOTESLIST_ACTION = "show-notes-list";
    public const string EXPORT_PDF_ACTION = "export-pdf";

    public Notebook notebook { get; construct; }

    private Note? _current_note;
    public Note? current_note {
        get { return _current_note; }
        set {
            if (_current_note != null) {
                _current_note.close ();
            }

            _current_note = value;

            export_button.sensitive = _current_note != null;

            if (_current_note != null) {
                _current_note.open.begin ();
            }
        }
    }

    private Viewport viewport;
    private ToolStore tool_store;
    private Renderer renderer;

    private Gtk.MenuButton export_button;
    private Canvas canvas;

    public NoteView (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        viewport = new Viewport ();
        tool_store = new ToolStore ();

        renderer = new Renderer (viewport, tool_store);
        bind_property ("current-note", renderer, "note", SYNC_CREATE);

        var toggle_notes_list_button = new Gtk.ToggleButton () {
            icon_name = "folder",
            tooltip_text = _("Toggle notes list"),
            action_name = ACTION_PREFIX + SHOW_NOTESLIST_ACTION
        };

        var export_menu = new Menu ();
        export_menu.append (_("Export PDF"), ACTION_PREFIX + EXPORT_PDF_ACTION);

        export_button = new Gtk.MenuButton () {
            icon_name = "document-export",
            tooltip_text = _("Export"),
            menu_model = export_menu
        };

        var header_bar = new Adw.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        header_bar.pack_start (toggle_notes_list_button);
        header_bar.pack_start (export_button);

        canvas = new Canvas (viewport, tool_store, renderer);
        bind_property ("current-note", canvas, "note", SYNC_CREATE);

        var notes_list = new NotesList (notebook);
        bind_property ("current-note", notes_list, "selected-note", SYNC_CREATE | BIDIRECTIONAL);

        var split_view = new Adw.OverlaySplitView () {
            content = canvas,
            sidebar = notes_list,
            vexpand = true,
        };

        var main_box = new Granite.Box (VERTICAL, NONE);
        main_box.append (header_bar);
        main_box.append (new Gtk.Separator (HORIZONTAL));
        main_box.append (split_view);

        child = main_box;
        notebook.bind_property ("name", this, "title", SYNC_CREATE);

        var show_noteslist_action = new PropertyAction (SHOW_NOTESLIST_ACTION, split_view, "show-sidebar");

        var export_pdf_action = new SimpleAction (EXPORT_PDF_ACTION, null);
        export_pdf_action.activate.connect (on_export_pdf);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (show_noteslist_action);
        action_group.add_action (export_pdf_action);
        insert_action_group (ACTION_GROUP_PREFIX, action_group);
    }

    private async void on_export_pdf () {
        if (current_note == null) {
            return;
        }

        var exporter = new PdfExporter ((Gtk.Window) get_root (), renderer, current_note);

        try {
            yield exporter.export ();
        } catch (Error e) {
            warning ("Failed to export note: %s", e.message);
        }
    }
}
