/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Engine : Object, Gdk.Paintable {
    private Renderer renderer;
    private Viewport viewport;

    private Content? content;
    private Tool? tool;

    private Graphene.Size last_snapshot_size = { 0, 0 };
    private RenderFlags next_render_flags = NONE;

    construct {
        renderer = new Renderer ();
        viewport = new Viewport ();
    }

    public void load_content (Content content) {
        if (tool != null && this.content != null) {
            tool.deactivate (this.content);
        }

        this.content = content;

        if (tool != null && this.content != null) {
            tool.activate (this.content);
        }

        viewport.load_and_set_state_id (content.id, last_snapshot_size);

        maybe_queue_render (TOOL_CHANGED | ZOOM_CHANGED | TRANSLATION_CHANGED | STROKES_CHANGED);
    }

    public void load_tool (Tool? tool) {
        RenderFlags flags = NONE;

        if (this.tool != null && content != null) {
            this.tool.deactivate (content);

            flags |= TOOL_CHANGED;
        }

        this.tool = tool;

        if (this.tool != null && content != null) {
            this.tool.activate (content);

            flags |= TOOL_CHANGED;
        }

        maybe_queue_render (flags);
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        last_snapshot_size.width = (float) width;
        last_snapshot_size.height = (float) height;

        var bounds = Graphene.Rect () {
            size = last_snapshot_size
        };

        renderer.snapshot (content, viewport, (Gtk.Snapshot) snapshot, bounds, next_render_flags);

        if (tool != null) {
            renderer.snapshot_tool (tool, viewport, (Gtk.Snapshot) snapshot, next_render_flags);
        }

        next_render_flags = NONE;
    }

    private void maybe_queue_render (RenderFlags flags) {
        if (flags == NONE) {
            return;
        }

        next_render_flags |= flags;

        if (next_render_flags != NONE) {
            invalidate_contents ();
        }
    }

    public void move_view (float dx, float dy) {
        viewport.move_by_widget_coords (dx, dy);

        maybe_queue_render (TRANSLATION_CHANGED);
    }

    public void zoom_view (float scale, Graphene.Point center) {
        viewport.zoom_with_center (scale, center);

        maybe_queue_render (ZOOM_CHANGED);
    }

    public void go_to_origin () {
        viewport.go_to_origin (last_snapshot_size);

        maybe_queue_render (TRANSLATION_CHANGED | ZOOM_CHANGED);
    }

    public void start_event (Graphene.Point point) {
        if (tool == null || content == null) {
            return;
        }

        var transformed = viewport.widget_to_content_coords (point);
        var flags = tool.start (content, transformed.x, transformed.y);

        maybe_queue_render (flags);
    }

    public void motion_event (Graphene.Point point, Graphene.Point[] backlog) {
        if (tool == null || content == null) {
            return;
        }

        var transformed = viewport.widget_to_content_coords (point);
        var transformed_backlog = new Graphene.Point[backlog.length];

        for (int i = 0; i < backlog.length; i++) {
            transformed_backlog[i] = viewport.widget_to_content_coords (backlog[i]);
        }

        var flags = tool.motion (content, transformed.x, transformed.y, transformed_backlog);

        maybe_queue_render (flags);
    }

    public void commit_event (Graphene.Point point) {
        if (tool == null || content == null) {
            return;
        }

        var transformed = viewport.widget_to_content_coords (point);
        var flags = tool.commit (content, transformed.x, transformed.y);

        maybe_queue_render (flags);
    }

    public async void export_pdf (File target_file) throws Error {
        var exporter = new PdfExporter (renderer, content);
        yield exporter.export (target_file);
    }
}
