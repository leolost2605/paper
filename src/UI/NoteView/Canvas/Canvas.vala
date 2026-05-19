/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Granite.Bin {
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    private InputHandler input_handler;
    private MoveHandler move_handler;

    public Canvas (ToolSelection tool_selection, Engine engine) {
        Object (tool_selection: tool_selection, engine: engine);
    }

    construct {
        var picture = new Gtk.Picture.for_paintable (engine);

        input_handler = new InputHandler (picture, tool_selection, engine);
        move_handler = new MoveHandler (picture, engine);

        child = picture;
        set_cursor (new Gdk.Cursor.from_name ("none", null));
    }
}
