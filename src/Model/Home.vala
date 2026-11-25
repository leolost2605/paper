/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[SingleInstance]
public class Paper.Home : Object {
    private Gtk.MapListModel _map_list_model;
    public ListModel files { get { return _map_list_model; } }

    public string? uri { get { return root_dir?.uri; } }

    private Directory? root_dir;

    construct {
        _map_list_model = new Gtk.MapListModel (null, map_func);

        load.begin ();
    }

    private static Object map_func (owned Object obj) {
        return obj;
    }

    private async void load () {
        var data_dir = Environment.get_user_data_dir ();

        var path = Path.build_filename (data_dir, "paper_documents");

        var root = yield FileBase.get_for_path (path);

        if (root == null) {
            DirUtils.create_with_parents (path, 0755);
            root = yield FileBase.get_for_path (path);
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
