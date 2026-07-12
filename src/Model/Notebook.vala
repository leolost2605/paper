/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.Notebook : Object {
    public string uri { get; construct; }

    public Directory? root { get; private set; }

    public bool invalid { get { return root == null; } }
    public string name { get { return root?.display_name ?? _("Invalid Notebook"); } }

    public Notebook (string uri) {
        Object (uri: uri);
    }

    construct {
        notify["root"].connect (on_root_changed);

        // TODO: Monitor the file to catch if it gets deleted
        load_root.begin ();
    }

    private void on_root_changed () {
        notify_property ("invalid");
        notify_property ("name");
    }

    private async void load_root () {
        if (root != null) {
            return;
        }

        var root_dir = yield FileBase.get_for_uri (uri);

        if (root_dir == null) {
            warning ("Failed to load notebook %s: No such file or directory", uri);
            return;
        }

        if (!(root_dir is Directory)) {
            warning ("Failed to load notebook %s: Not a directory", uri);
            return;
        }

        root = (Directory) root_dir;
        root.load ();
    }
}
