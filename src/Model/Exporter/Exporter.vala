/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public abstract class Quicknote.Exporter : Object {
    public Gtk.Window parent_window { get; construct; }

    public async abstract void export () throws Error;

    protected async File? select_location (string initial_name) throws Error {
        var dialog = new Gtk.FileDialog () {
            title = _("Export Note"),
            initial_name = initial_name,
        };

        return yield dialog.save (parent_window, null);
    }
}
