/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/welcome-view.ui")]
public class Paper.WelcomeView : Adw.NavigationPage {
    public NotebookManager notebook_manager { get; construct; }

    public WelcomeView (NotebookManager notebook_manager) {
        Object (notebook_manager: notebook_manager);
    }

    [GtkCallback]
    private void on_activate (Gtk.ListView list_view, uint position) {
        var notebook = (Notebook) list_view.model.get_item (position);
        activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTEBOOK_ACTION, new Variant.string (notebook.uri));
    }
}
