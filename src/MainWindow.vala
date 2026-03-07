/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class Quicknote.MainWindow : Adw.ApplicationWindow {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "io.github.leolost2605.quicknote",
            title: _("My App Name")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("io/github/leolost2605/quicknote/");
	}

    construct {
        start.begin ();
    }

    private async void start () {
        var path = Environment.get_user_data_dir () + "/my-first-notebook";
        var notebook = yield new Notebook (path);
        var note_view = new NoteView (notebook);
        content = note_view;
    }
}
