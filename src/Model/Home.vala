/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[SingleInstance]
public class Paper.Home : Object {
    private Gtk.MapListModel _map_list_model;
    public ListModel files { get { return _map_list_model; } }

    public string path { get; private set; }
    public string uri { get; private set; }

    private Directory? root_dir;

    construct {
        _map_list_model = new Gtk.MapListModel (null, map_func);

        var data_dir = Environment.get_user_data_dir ();

        path = Path.build_filename (data_dir, "paper_documents");

        try {
            uri = Filename.to_uri (path);
        } catch (Error e) {
            critical ("Failed to get URI for home path: %s", path);
            return;
        }

        load.begin ();
    }

    private static Object map_func (owned Object obj) {
        return obj;
    }

    private async void load () {
        var root = yield FileBase.get_for_uri (uri);

        if (root == null) {
            DirUtils.create_with_parents (path, 0755);
            root = yield FileBase.get_for_uri (uri);
        }

        if (root == null || !(root is Directory)) {
            critical ("Failed to find a place to store documents");
            return;
        }

        root_dir = (Directory) root;
        root_dir.load ();

        _map_list_model.model = root_dir.children;
    }
}
