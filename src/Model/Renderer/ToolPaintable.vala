/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.ToolPaintable : Object, Gdk.Paintable {
    public Tool tool { get; construct; }
    public Viewport viewport { get; construct; }
    public Renderer renderer { get; construct; }

    public ToolPaintable (Tool tool, Viewport viewport, Renderer renderer) {
        Object (tool: tool, viewport: viewport, renderer: renderer);
    }

    construct {
        tool.changed.connect (invalidate_contents);
        viewport.notify.connect (invalidate_contents);
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        renderer.snapshot_tool (tool, viewport, (Gtk.Snapshot) snapshot);
    }
}
