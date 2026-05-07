/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.LibraryView : Adw.NavigationPage {
    public NotebookManager notebook_manager { get; construct; }

    public LibraryView (NotebookManager notebook_manager) {
        Object (notebook_manager: notebook_manager);
    }

    construct {
        var notebook_list = new NotebookList (notebook_manager.notebooks);

        var new_notebook_button = new Gtk.Button.with_label (_("New Notebook")) {
            action_name = MainWindow.ACTION_PREFIX + MainWindow.CREATE_NOTEBOOK_ACTION,
            halign = CENTER,
        };

        var content_box = new Granite.Box (VERTICAL);
        content_box.append (notebook_list);
        content_box.append (new_notebook_button);

        var status_page = new Adw.StatusPage () {
            title = _("Recent notebooks"),
            description = _("Or create a notebook to get started."),
            child = content_box,
        };

        var header_bar = new Adw.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        var toolbox = new Adw.ToolbarView () {
            content = status_page,
        };
        toolbox.add_top_bar (header_bar);

        child = toolbox;
        title = _("Library");
    }
}
