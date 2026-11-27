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

        sidebar_items.append (new FileList (_("Home"), home.files, home.uri, "user-home"));
        sidebar_items.append (new FileList (_("Recents"), new ListStore (typeof (FileBase)), null, "document-open-recent"));
    }
}
