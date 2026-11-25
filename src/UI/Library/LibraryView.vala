/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/library-view.ui")]
public class Paper.LibraryView : Adw.NavigationPage {
    [GtkChild]
    private unowned ListStore sidebar_items;

    private Home home;

    construct {
        home = new Home ();

        sidebar_items.append (new LibrarySidebarItem ("user-home", _("Home"), home.files));
        sidebar_items.append (new LibrarySidebarItem ("document-open-recent", _("Recents"), new ListStore (typeof (FileBase))));
    }
}
