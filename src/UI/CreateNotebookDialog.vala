/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.CreateNotebookDialog : Gtk.Window {
    public NotebookManager notebook_manager { get; construct; }

    private Gtk.Entry name_entry;
    private Gtk.Button location_button;

    private Gtk.Button create_button;

    private File? selected_location = null;

    public CreateNotebookDialog (NotebookManager notebook_manager) {
        Object (notebook_manager: notebook_manager);
    }

    construct {
        var name_label = new Granite.HeaderLabel (_("Notebook name:")) {
            halign = START,
        };

        name_entry = new Gtk.Entry () {
            placeholder_text = _("Enter notebook name"),
            activates_default = true,
        };
        name_entry.changed.connect (update_create_button_sensitivity);

        var location_label = new Granite.HeaderLabel (_("Location:")) {
            halign = START,
        };

        location_button = new Gtk.Button.with_label (_("Select Location"));
        location_button.clicked.connect (select_location);

        var cancel_button = new Gtk.Button.with_label (_("Cancel")) {
            action_name = "window.close",
        };

        create_button = new Gtk.Button.with_label (_("Create")) {
            sensitive = false,
        };
        create_button.clicked.connect (create_notebook);
        create_button.add_css_class (Granite.CssClass.SUGGESTED);

        var button_box = new Granite.Box (HORIZONTAL, HALF) {
            halign = END,
        };
        button_box.append (cancel_button);
        button_box.append (create_button);

        var content = new Granite.Box (VERTICAL) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
        };
        content.append (name_label);
        content.append (name_entry);
        content.append (location_label);
        content.append (location_button);
        content.append (button_box);

        titlebar = new Granite.Bin () {
            visible = false,
        };
        child = content;
        default_width = 500;
        default_height = 100;
        resizable = false;
        default_widget = create_button;
    }

    private async void select_location () {
        var dialog = new Gtk.FileDialog ();

        try {
            selected_location = yield dialog.select_folder (this, null);
            location_button.label = selected_location.get_basename ();
        } catch (Error e) {
            warning ("Failed to select folder: %s", e.message);
            return;
        }

        update_create_button_sensitivity ();
    }

    private void update_create_button_sensitivity () {
        create_button.sensitive = selected_location != null && name_entry.text.strip () != "";
    }

    private void create_notebook () {
        notebook_manager.create_notebook.begin (selected_location.get_child (name_entry.text));
        close ();
    }
}
