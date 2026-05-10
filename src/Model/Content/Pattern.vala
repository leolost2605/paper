/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pattern : Object {
    public enum Style {
        GRID,
    }

    public Database database { private get; construct; }

    public bool active { get; set; default = false; }

    public Style style { get; set; default = GRID; }
    public float width { get; set; default = 20; }
    public float height { get; set; default = 20; }
    public Gdk.RGBA? color { get; set; default = Gdk.RGBA () { red = 0.26f, green = 0.68f, blue = 0.94f, alpha = 0.5f }; }

    private static HashTable<Style, PatternRenderer> renderers;

    public Pattern (Database database) {
        Object (database: database);
    }

    static construct {
        renderers = new HashTable<Style, PatternRenderer> (null, null);
        renderers[Style.GRID] = new GridRenderer ();
    }

    construct {
        database.ready.connect (load_from_database);
        notify.connect (save_to_database);
    }

    private void load_from_database () {
        try {
            if (!database.has_pattern ()) {
                return;
            }

            bool active;
            Style style;
            float width, height;
            Gdk.RGBA color;

            database.get_pattern (out active, out style, out width, out height, out color);

            this.active = active;
            this.style = style;
            this.width = width;
            this.height = height;
            this.color = color;
        } catch (Error e) {
            warning ("Failed to load pattern from database: %s", e.message);
        }
    }

    private void save_to_database () {
        try {
            database.set_pattern (active, style, width, height, color);
        } catch (Error e) {
            warning ("Failed to save pattern to database: %s", e.message);
        }
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }

        renderers[style].snapshot (width, height, color, snapshot, bounds);
    }
}
