/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.OriginIndicator : Object {
    public Database database { private get; construct; }

    public bool active { get; set; default = true; }

    public OriginIndicator (Database database) {
        Object (database: database);
    }

    construct {
        database.ready.connect (load_from_database);
        notify.connect (save_to_database);
    }

    private void load_from_database () {
        try {
            if (!database.has_origin_indicator ()) {
                return;
            }

            bool active;
            database.get_origin_indicator (out active);

            this.active = active;
        } catch (Error e) {
            warning ("Failed to load origin indicator from database: %s", e.message);
        }
    }

    private void save_to_database () {
        try {
            database.set_origin_indicator (active);
        } catch (Error e) {
            warning ("Failed to save origin indicator to database: %s", e.message);
        }
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }

        var path_builder = new Gsk.PathBuilder ();
        path_builder.move_to (-5, -5);
        path_builder.line_to (5, 5);
        path_builder.move_to (-5, 5);
        path_builder.line_to (5, -5);

        var path = path_builder.to_path ();
        var stroke = new Gsk.Stroke (1.0f);
        var color = Gdk.RGBA ();
        color.parse ("green");

        snapshot.append_stroke (path, stroke, color);
    }
}
