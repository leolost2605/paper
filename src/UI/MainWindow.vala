/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class Paper.MainWindow : Adw.ApplicationWindow {
    public const string ACTION_PREFIX = "win.";
    public const string CREATE_NOTEBOOK_ACTION = "create-notebook";
    public const string OPEN_NOTEBOOK_ACTION = "open-notebook";

    private NotebookManager notebook_manager;
    private Adw.NavigationView navigation_view;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "io.github.leolost2605.paper",
            title: _("My App Name")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("io/github/leolost2605/paper/");
	}

    construct {
        notebook_manager = new NotebookManager ();

        navigation_view = new Adw.NavigationView ();
        navigation_view.add (new WelcomeView (notebook_manager));

        content = navigation_view;

        var create_notebook_action = new SimpleAction (CREATE_NOTEBOOK_ACTION, null);
        create_notebook_action.activate.connect (on_create_notebook);
        var open_notebook_action = new SimpleAction (OPEN_NOTEBOOK_ACTION, VariantType.STRING);
        open_notebook_action.activate.connect (on_open_notebook);

        add_action (create_notebook_action);
        add_action (open_notebook_action);
    }

    private void on_create_notebook () {
        var dialog = new CreateNotebookDialog (notebook_manager) {
            transient_for = this,
        };

        dialog.present ();
    }

    private void on_open_notebook (Variant? parameter) {
        var uri = parameter.get_string ();
        var notebook = notebook_manager.get_notebook_by_uri (uri);

        if (notebook == null || notebook.invalid) {
            warning ("Notebook with URI %s not found or invalid", uri);
            return;
        }

        var view = new NoteView (notebook);
        navigation_view.push (view);
    }
}
