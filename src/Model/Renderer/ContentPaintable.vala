/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.ContentPaintable : Object, Gdk.Paintable {
    public Content content { get; construct; }
    public ToolStore tool_store { get; construct; }
    public Viewport viewport { get; construct; }
    public Renderer renderer { get; construct; }

    public ContentPaintable (Content content, ToolStore tool_store, Viewport viewport, Renderer renderer) {
        Object (content: content, tool_store: tool_store, viewport: viewport, renderer: renderer);
    }

    construct {
        content.changed.connect (invalidate_contents);
        viewport.notify.connect (invalidate_contents);
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        var bounds = Graphene.Rect () {
            origin = { 0, 0 },
            size = { (float) width, (float) height },
        };

        renderer.snapshot (content, tool_store.active_tool, viewport, (Gtk.Snapshot) snapshot, bounds);
    }
}
