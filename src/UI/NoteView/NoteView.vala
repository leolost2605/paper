/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/note-view.ui")]
public class Paper.NoteView : Adw.NavigationPage {
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
                _current_note.open.begin ();
            }
        }
    }

    [GtkChild]
    private unowned Adw.ToolbarView toolbar_view;

    private ToolStore tool_store;
    private ToolSelection tool_selection;
    private Engine engine;

    construct {
        engine = new Engine ();

        tool_store = new ToolStore ("test");
        tool_selection = new ToolSelection (tool_store.tools);
        tool_selection.notify["active-tool"].connect (() => engine.load_tool (tool_selection.active_tool));
        engine.load_tool (tool_selection.active_tool);

        toolbar_view.content = new DrawingArea (tool_store, tool_selection, engine);

        var export_pdf_action = new SimpleAction ("export-pdf", null);
        export_pdf_action.activate.connect (on_export_pdf);

        var open_properties_action = new SimpleAction ("open-properties", null);
        open_properties_action.activate.connect (on_open_properties);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (export_pdf_action);
        action_group.add_action (open_properties_action);
        insert_action_group ("note-view", action_group);
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
