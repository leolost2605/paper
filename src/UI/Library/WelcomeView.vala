/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.WelcomeView : Adw.NavigationPage {
    public NotebookManager notebook_manager { get; construct; }

    public WelcomeView (NotebookManager notebook_manager) {
        Object (notebook_manager: notebook_manager);
    }

    construct {
        var notebook_list = new NotebookList (notebook_manager.notebooks);

        var header_bar = new Adw.HeaderBar () {
            //  show_title = false
        };
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        var new_notebook_icon = new Gtk.Image.from_icon_name ("list-add-symbolic");
        var new_notebook_label = new Gtk.Label (_("New Notebook..."));

        var new_notebook_box = new Granite.Box (HORIZONTAL, NONE);
        new_notebook_box.append (new_notebook_icon);
        new_notebook_box.append (new_notebook_label);

        var new_notebook_button = new Gtk.Button.with_label (_("New Notebook...")) {
            action_name = MainWindow.ACTION_PREFIX + MainWindow.CREATE_NOTEBOOK_ACTION,
            child = new_notebook_box
        };
        new_notebook_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_start (new_notebook_button);

        var action_bar_clamp = new Adw.Clamp () {
            child = action_bar,
            maximum_size = 800,
            tightening_threshold = 600,
        };

        var toolbox = new Adw.ToolbarView () {
            content = notebook_list,
            bottom_bar_style = RAISED
        };
        toolbox.add_top_bar (header_bar);
        toolbox.add_bottom_bar (action_bar_clamp);

        child = toolbox;
        title = _("Home");
    }
}
