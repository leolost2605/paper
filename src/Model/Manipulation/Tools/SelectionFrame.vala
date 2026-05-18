/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.SelectionFrame : Object {
    public Graphene.Rect item_bounds { get; construct; }

    public SelectionFrame (Graphene.Rect item_bounds) {
        Object (item_bounds: item_bounds);
    }

    public bool contains (Graphene.Point point) {
        return item_bounds.contains_point (point);
    }

    public void snapshot (Gtk.Snapshot snapshot) {
        var path_builder = new Gsk.PathBuilder ();
        path_builder.add_rect (item_bounds);
        var path = path_builder.to_path ();

        var stroke = new Gsk.Stroke (1.0f);
        var color = Gdk.RGBA ();
        color.parse ("blue");

        snapshot.append_stroke (path, stroke, color);
    }
}
