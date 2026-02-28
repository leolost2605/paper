/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Adw.NavigationPage {
    public Note note { get; set; }

    private Renderer renderer;
    private Viewport viewport;

    private MoveHandler move_handler;

    private ToolStore tool_store;
    private Manipulator manipulator;
    private InputHandler input_handler;

    construct {
        viewport = new Viewport ();
        renderer = new Renderer (viewport);
        bind_property ("note", renderer, "note", SYNC_CREATE);

        var draw_target = new DrawTarget (renderer);

        move_handler = new MoveHandler (draw_target, viewport);

        tool_store = new ToolStore ();
        manipulator = new Manipulator (tool_store);
        bind_property ("note", manipulator, "note", SYNC_CREATE);

        input_handler = new InputHandler (draw_target, viewport, manipulator);

        child = draw_target;

        tool_store.add_tool (new Pen ());
        tool_store.add_tool (new Eraser ());
    }
}
