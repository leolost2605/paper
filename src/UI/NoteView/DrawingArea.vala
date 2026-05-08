/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.DrawingArea : Granite.Bin {
    public ToolStore tool_store { private get; construct; }
    public Renderer renderer { private get; construct; }

    public Content? content { get; set; }

    public DrawingArea (ToolStore tool_store, Renderer renderer) {
        Object (tool_store: tool_store, renderer: renderer);
    }

    construct {
        var canvas = new Canvas (tool_store, renderer);
        bind_property ("content", canvas, "content", SYNC_CREATE);

        var penbar = new Penbar (tool_store) {
            halign = START,
            valign = CENTER
        };

        var overlay = new Gtk.Overlay () {
            child = canvas,
        };
        overlay.add_overlay (penbar);

        child = overlay;

        tool_store.add_tool (new Pen ());
        tool_store.add_tool (new Eraser ());
    }
}
