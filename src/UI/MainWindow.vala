/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/main-window.ui")]
public class Paper.MainWindow : Adw.ApplicationWindow {
    public const string ACTION_PREFIX = "win.";
    public const string OPEN_NOTE_ACTION = "open-note";

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
        navigation_view.add (new LibraryView ());

        note_view = new NoteView ();

        var open_note_action = new SimpleAction (OPEN_NOTE_ACTION, VariantType.STRING);
        open_note_action.activate.connect (on_open_note);

        add_action (open_note_action);
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
