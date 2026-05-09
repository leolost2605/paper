/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Granite.Bin {
    public ToolStore tool_store { private get; construct; }
    public Renderer renderer { private get; construct; }

    public Content? content {
        set {
            manipulator.content = value;

            if (value == null) {
                content_picture.paintable = null;
                return;
            }

            content_picture.paintable = new ContentPaintable (value, tool_store, viewport, renderer);
        }
    }

    private Gtk.Picture content_picture;

    private Viewport viewport;

    private MoveHandler move_handler;

    private Manipulator manipulator;
    private InputHandler input_handler;

    public Canvas (ToolStore tool_store, Renderer renderer) {
        Object (tool_store: tool_store, renderer: renderer);
    }

    construct {
        content_picture = new Gtk.Picture ();

        viewport = new Viewport ();

        move_handler = new MoveHandler (content_picture, viewport);

        manipulator = new Manipulator (tool_store);

        input_handler = new InputHandler (content_picture, viewport, manipulator);

        child = content_picture;
        set_cursor (new Gdk.Cursor.from_name ("none", null));
    }
}
