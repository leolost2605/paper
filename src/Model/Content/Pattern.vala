/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pattern : Object {
    public enum Style {
        GRID,
    }

    public bool active { get; set; default = false; }

    public Style style { get; set; default = GRID; }
    public float width { get; set; default = 20; }
    public float height { get; set; default = 20; }
    public Gdk.RGBA? color { get; set; }

    private static HashTable<Style, PatternRenderer> renderers;

    static construct {
        renderers = new HashTable<Style, PatternRenderer> (null, null);
        renderers[Style.GRID] = new GridRenderer ();
    }

    construct {
        var color = Gdk.RGBA ();
        color.parse ("#43adf0");
        this.color = color;
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }

        renderers[style].snapshot (width, height, color, snapshot, bounds);
    }
}
