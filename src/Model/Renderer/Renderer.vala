/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Renderer : Object {
    public Viewport viewport { get; construct; }
    public ToolStore tool_store { get; construct; }

    public Note? note { get; set; }

    public Renderer (Viewport viewport, ToolStore tool_store) {
        Object (viewport: viewport, tool_store: tool_store);
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (note == null) {
            return;
        }

        note.background.snapshot (snapshot, bounds);

        snapshot.save ();
        snapshot.transform (viewport.get_transform ());

        foreach (var item in note.get_items_intersecting_rect (bounds)) {
            item.snapshot (snapshot);
        }

        tool_store.active_tool?.snapshot (snapshot);

        snapshot.restore ();
    }
}
