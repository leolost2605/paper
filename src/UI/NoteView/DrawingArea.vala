/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.DrawingArea : Granite.Bin {
    public ToolStore tool_store { private get; construct; }
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    public DrawingArea (ToolStore tool_store, ToolSelection tool_selection, Engine engine) {
        Object (tool_store: tool_store, tool_selection: tool_selection, engine: engine);
    }

    construct {
        var canvas = new Canvas (tool_selection, engine);

        var penbar = new Penbar (tool_store, tool_selection) {
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
        tool_store.add_tool (new RectangleSelector ());
    }
}
