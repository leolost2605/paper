/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Granite.Bin {
    public ToolSelection tool_selection { private get; construct; }
    public Renderer renderer { private get; construct; }

    public Content? content {
        set {
            input_handler.content = value;

            if (value == null) {
                content_picture.paintable = null;
                return;
            }

            content_picture.paintable = new ContentPaintable (value, viewport, renderer);
        }
    }

    private Gtk.Picture content_picture;
    private Gtk.Picture tool_picture;

    private Viewport viewport;

    private InputHandler input_handler;
    private MoveHandler move_handler;

    public Canvas (ToolSelection tool_selection, Renderer renderer) {
        Object (tool_selection: tool_selection, renderer: renderer);
    }

    construct {
        content_picture = new Gtk.Picture ();
        tool_picture = new Gtk.Picture ();

        var overlay = new Gtk.Overlay () {
            child = content_picture
        };
        overlay.add_overlay (tool_picture);

        viewport = new Viewport ();

        input_handler = new InputHandler (overlay, viewport, tool_selection);
        move_handler = new MoveHandler (overlay, viewport);

        child = overlay;
        set_cursor (new Gdk.Cursor.from_name ("none", null));

        tool_selection.notify["active-tool"].connect (on_tool_changed);
        on_tool_changed ();
    }

    private void on_tool_changed () {
        if (tool_selection.active_tool == null) {
            tool_picture.paintable = null;
            return;
        }

        tool_picture.paintable = new ToolPaintable (tool_selection.active_tool, viewport, renderer);
    }
}
