/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Granite.Bin {
    public ToolStore tool_store { private get; construct; }
    public Renderer renderer { private get; construct; }

    private Content? _content;
    public Content? content {
        private get { return _content; }
        set {
            if (_content != null) {
                _content.changed.disconnect (draw_target.queue_draw);
            }

            _content = value;

            manipulator.content = _content;

            if (_content != null) {
                _content.changed.connect (draw_target.queue_draw);
            }

            draw_target.queue_draw ();
        }
    }

    private Viewport viewport;
    private DrawTarget draw_target;

    private MoveHandler move_handler;

    private Manipulator manipulator;
    private InputHandler input_handler;

    public Canvas (ToolStore tool_store, Renderer renderer) {
        Object (tool_store: tool_store, renderer: renderer);
    }

    construct {
        draw_target = new DrawTarget ();
        draw_target.request_render.connect (on_request_render);
        draw_target.set_cursor (new Gdk.Cursor.from_name ("none", null));

        viewport = new Viewport ();
        viewport.notify.connect (draw_target.queue_draw);

        move_handler = new MoveHandler (draw_target, viewport);

        manipulator = new Manipulator (tool_store);

        input_handler = new InputHandler (draw_target, viewport, manipulator);

        child = draw_target;
    }

    private void on_request_render (Gtk.Snapshot snapshot) {
        if (content == null) {
            return;
        }

        renderer.snapshot (content, tool_store.active_tool, viewport, snapshot, draw_target.get_bounds ());
    }
}
