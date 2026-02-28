/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.NotesList : Adw.NavigationPage {
    public Notebook notebook { get; construct; }

    public NotesList (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
    }
}
