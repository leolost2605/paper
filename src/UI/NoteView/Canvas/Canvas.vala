/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Granite.Bin {
    public ToolSelection tool_selection { private get; construct; }
    public Renderer renderer { private get; construct; }

    public Content? content {
        set {
            tool_holder.content = value;

            if (value == null) {
                content_picture.paintable = null;
                return;
            }

            content_picture.paintable = new ContentPaintable (value, viewport, renderer);
        }
    }

    private Gtk.Picture content_picture;

    private Viewport viewport;

    private ToolHolder tool_holder;

    private MoveHandler move_handler;

    public Canvas (ToolSelection tool_selection, Renderer renderer) {
        Object (tool_selection: tool_selection, renderer: renderer);
    }

    construct {
        content_picture = new Gtk.Picture ();

        viewport = new Viewport ();

        tool_holder = new ToolHolder (tool_selection, viewport);

        var overlay = new Gtk.Overlay () {
            child = content_picture
        };
        overlay.add_overlay (tool_holder);

        move_handler = new MoveHandler (overlay, viewport);

        child = overlay;
        set_cursor (new Gdk.Cursor.from_name ("none", null));
    }
}
