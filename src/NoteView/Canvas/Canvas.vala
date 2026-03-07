/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Adw.NavigationPage {
    public Note note { get; set; }

    private Viewport viewport;
    private ToolStore tool_store;

    private Renderer renderer;

    private MoveHandler move_handler;

    private Manipulator manipulator;
    private InputHandler input_handler;

    construct {
        viewport = new Viewport ();

        tool_store = new ToolStore ();

        renderer = new Renderer (viewport, tool_store);
        bind_property ("note", renderer, "note", SYNC_CREATE);

        var draw_target = new DrawTarget (renderer);
        viewport.notify.connect (draw_target.queue_draw);
        notify["note"].connect (draw_target.queue_draw);

        move_handler = new MoveHandler (draw_target, viewport);

        manipulator = new Manipulator (tool_store);
        bind_property ("note", manipulator, "note", SYNC_CREATE);

        input_handler = new InputHandler (draw_target, viewport, manipulator);

        var penbar = new Penbar (tool_store) {
            halign = START,
            valign = CENTER
        };

        var overlay = new Gtk.Overlay () {
            child = draw_target,
        };
        overlay.add_overlay (penbar);

        child = overlay;

        tool_store.add_tool (new Pen ());
        tool_store.add_tool (new Eraser ());
    }
}
