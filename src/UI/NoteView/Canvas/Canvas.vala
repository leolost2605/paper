/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Canvas : Adw.NavigationPage {
    public ToolStore tool_store { private get; construct; }
    public Renderer renderer { private get; construct; }

    public Content? content { get; set; }

    private MoveHandler move_handler;

    private Manipulator manipulator;
    private InputHandler input_handler;

    public Canvas (ToolStore tool_store, Renderer renderer) {
        Object (tool_store: tool_store, renderer: renderer);
    }

    construct {
        var viewport = new Viewport ();

        var draw_target = new DrawTarget (renderer, tool_store, viewport);
        bind_property ("content", draw_target, "content", SYNC_CREATE);

        move_handler = new MoveHandler (draw_target, viewport);

        manipulator = new Manipulator (tool_store);
        bind_property ("content", manipulator, "content", SYNC_CREATE);

        input_handler = new InputHandler (draw_target, viewport, manipulator);

        child = draw_target;
    }
}
