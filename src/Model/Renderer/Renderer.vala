/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Renderer : Object {
    public Viewport viewport { get; construct; }

    public Note note { get; set; }

    public Renderer (Viewport viewport) {
        Object (viewport: viewport);
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        note.background.snapshot (snapshot, bounds);

        snapshot.save ();
        snapshot.transform (viewport.get_transform ());

        foreach (var item in note.items.get_intersecting_rect (bounds)) {
            item.snapshot (snapshot);
        }

        if (note.current_item != null) {
            note.current_item.snapshot (snapshot);
        }

        snapshot.restore ();
    }
}
