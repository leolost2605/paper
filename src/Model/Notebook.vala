/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Notebook : Object {
    public Directory root { get; construct; }

    public async Notebook (string path) {
        var file = yield FileBase.get_for_path (path);

        if (file == null) {
            DirUtils.create (path, -1);
            file = yield FileBase.get_for_path (path);
        }

        Object (root: (Directory) yield FileBase.get_for_path (path));
    }

    construct {
        root.load ();
    }
}
