/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.DrawTarget : Gtk.Widget {
    public signal void request_render (Gtk.Snapshot snapshot);

    public Graphene.Rect get_bounds () {
        Graphene.Rect bounds;
        compute_bounds (this, out bounds);
        return bounds;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        request_render (snapshot);
    }
}
