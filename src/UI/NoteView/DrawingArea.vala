/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.DrawingArea : Granite.Bin {
    public ToolStore tool_store { private get; construct; }
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    private SimpleAction undo_action;
    private SimpleAction redo_action;

    public DrawingArea (ToolStore tool_store, ToolSelection tool_selection, Engine engine) {
        Object (tool_store: tool_store, tool_selection: tool_selection, engine: engine);
    }

    construct {
        var canvas = new Canvas (tool_selection, engine);

        var penbar = new Penbar (tool_store, tool_selection) {
            halign = START,
            valign = CENTER
        };

        var selection_bar = new SelectionBar ();
        engine.bind_property ("has-selection", selection_bar, "should-show", SYNC_CREATE);

        var overlay = new Gtk.Overlay () {
            child = canvas,
        };
        overlay.add_overlay (penbar);
        overlay.add_overlay (selection_bar);

        child = overlay;

        engine.notify.connect (on_engine_notify);

        undo_action = new SimpleAction ("undo", null);
        undo_action.set_enabled (engine.can_undo);
        undo_action.activate.connect (engine.undo);

        redo_action = new SimpleAction ("redo", null);
        redo_action.set_enabled (engine.can_redo);
        redo_action.activate.connect (engine.redo);

        var delete_selection_action = new SimpleAction ("delete-selection", null);
        delete_selection_action.activate.connect (engine.delete_selection);

        var go_to_origin_action = new SimpleAction ("go-to-origin", null);
        go_to_origin_action.activate.connect (engine.go_to_origin);

        var import_pdf_action = new SimpleAction ("import-pdf", null);
        import_pdf_action.activate.connect (import_pdf);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (undo_action);
        action_group.add_action (redo_action);
        action_group.add_action (delete_selection_action);
        action_group.add_action (go_to_origin_action);
        action_group.add_action (import_pdf_action);
        insert_action_group ("drawing-area", action_group);
    }

    private void on_engine_notify (ParamSpec pspec) {
        switch (pspec.name) {
            case "can-undo":
                undo_action.set_enabled (engine.can_undo);
                break;

            case "can-redo":
                redo_action.set_enabled (engine.can_redo);
                break;
        }
    }

    private async void import_pdf () {
        var dialog = new Gtk.FileDialog () {
            title = _("Import PDF"),
        };

        try {
            var file = yield dialog.open ((Gtk.Window) get_root (), null);
            yield engine.import_pdf (file);
        } catch (Error e) {
            warning ("Failed to import PDF: %s", e.message);
        }
    }
}
