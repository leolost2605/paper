/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.DrawTarget : Gtk.Widget {
    public Renderer renderer { get; construct; }

    public DrawTarget (Renderer renderer) {
        Object (renderer: renderer);
    }

    construct {
        set_cursor (new Gdk.Cursor.from_name ("none", null));
    }

    public Graphene.Rect get_bounds () {
        Graphene.Rect bounds;
        compute_bounds (this, out bounds);
        return bounds;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        renderer.snapshot (snapshot, get_bounds ());
    }
}
