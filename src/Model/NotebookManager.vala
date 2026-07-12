/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.NotebookManager : Object {
    private Settings settings = new Settings ("io.github.leolost2605.paper");

    private ListStore notebook_store;
    public ListModel notebooks { get { return notebook_store; } }

    construct {
        notebook_store = new ListStore (typeof (Notebook));

        var uris = settings.get_strv ("notebooks");

        var new_notebooks = new Notebook[uris.length];

        for (int i = 0; i < uris.length; i++) {
            new_notebooks[i] = new Notebook (uris[i]);
        }

        notebook_store.splice (0, notebook_store.n_items, new_notebooks);
    }

    public async void create_notebook (File root) {
        DirUtils.create_with_parents (root.get_path (), 0755);
        register_notebook (root);
    }

    /**
     * Saves the location of the notebook to the library and loads it.
     * Used internally when creating a new notebook but can also be used to import notebooks.
     */
    public void register_notebook (File root) {
        var uris = settings.get_strv ("notebooks");
        uris += root.get_uri ();
        settings.set_strv ("notebooks", uris);

        var notebook = new Notebook (root.get_uri ());
        notebook_store.append (notebook);
    }

    public Notebook? get_notebook_by_uri (string uri) {
        for (uint i = 0; i < notebook_store.n_items; i++) {
            var notebook = (Notebook) notebook_store.get_item (i);

            if (notebook.uri == uri) {
                return notebook;
            }
        }

        return null;
    }
}
