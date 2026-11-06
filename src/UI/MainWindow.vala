/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/main-window.ui")]
public class Paper.MainWindow : Adw.ApplicationWindow {
    public const string ACTION_PREFIX = "win.";
    public const string CREATE_NOTEBOOK_ACTION = "create-notebook";
    public const string OPEN_NOTE_ACTION = "open-note";

    private NotebookManager notebook_manager;

    [GtkChild]
    private unowned Adw.NavigationView navigation_view;

    private NoteView note_view;

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("io/github/leolost2605/paper/");
	}

    construct {
        notebook_manager = new NotebookManager ();

        navigation_view.add (new LibraryView (notebook_manager));

        note_view = new NoteView ();

        var create_notebook_action = new SimpleAction (CREATE_NOTEBOOK_ACTION, null);
        create_notebook_action.activate.connect (on_create_notebook);
        var open_note_action = new SimpleAction (OPEN_NOTE_ACTION, VariantType.STRING);
        open_note_action.activate.connect (on_open_note);

        add_action (create_notebook_action);
        add_action (open_note_action);
    }

    private void on_create_notebook () {
        var dialog = new CreateNotebookDialog (notebook_manager) {
            transient_for = this,
        };

        dialog.present ();
    }

    private async void on_open_note (Variant? parameter) {
        var uri = parameter.get_string ();
        var note = yield FileBase.get_for_uri (uri);

        if (note == null || !(note is Note)) {
            warning ("Note with URI %s not found or invalid", uri);
            return;
        }

        note_view.current_note = (Note) note;

        navigation_view.push (note_view);
    }
}
