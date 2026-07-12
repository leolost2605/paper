/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.Canvas : Granite.Bin {
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    private InputHandler input_handler;
    private MoveHandler move_handler;

    public Canvas (ToolSelection tool_selection, Engine engine) {
        Object (tool_selection: tool_selection, engine: engine);
    }

    construct {
        var texture = Gdk.Texture.from_resource ("/io/github/leolost2605/paper/cursor-dot-small");
        var drawing_cursor = new Gdk.Cursor.from_texture (texture, 32, 32, null);

        var picture = new Gtk.Picture.for_paintable (engine) {
            cursor = drawing_cursor
        };

        input_handler = new InputHandler (picture, tool_selection, engine);
        move_handler = new MoveHandler (picture, engine);

        child = picture;
    }
}
