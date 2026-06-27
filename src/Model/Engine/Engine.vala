/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Engine : Object, Gdk.Paintable {
    public ToolSelection tool_selection { private get; construct; }

    private Renderer renderer;
    private Viewport viewport;

    private Content? content;

    private Graphene.Size last_snapshot_size = { 0, 0 };

    public Engine (ToolSelection tool_selection) {
        Object (tool_selection: tool_selection);
    }

    construct {
        renderer = new Renderer ();
        viewport = new Viewport ();
    }

    public void load_content (Content content) {
        this.content = content;

        invalidate_contents ();
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        last_snapshot_size.width = (float) width;
        last_snapshot_size.height = (float) height;

        var bounds = Graphene.Rect () {
            size = last_snapshot_size
        };

        renderer.snapshot (content, viewport, (Gtk.Snapshot) snapshot, bounds);

        if (tool_selection.active_tool != null) {
            renderer.snapshot_tool (tool_selection.active_tool, viewport, (Gtk.Snapshot) snapshot);
        }
    }

    public void move_view (float dx, float dy) {
        viewport.move_by_widget_coords (dx, dy);

        invalidate_contents ();
    }

    public void zoom_view (float scale, Graphene.Point center) {
        viewport.zoom_with_center (scale, center);

        invalidate_contents ();
    }

    public void go_to_origin () {
        viewport.go_to_origin (last_snapshot_size);

        invalidate_contents ();
    }

    public void start_event (Graphene.Point point) {
        var transformed = viewport.widget_to_content_coords (point);
        tool_selection.active_tool?.start (content, transformed.x, transformed.y);

        invalidate_contents ();
    }

    public void motion_event (Graphene.Point point, Graphene.Point[] backlog) {
        var transformed = viewport.widget_to_content_coords (point);
        var transformed_backlog = new Graphene.Point[backlog.length];

        for (int i = 0; i < backlog.length; i++) {
            transformed_backlog[i] = viewport.widget_to_content_coords (backlog[i]);
        }

        tool_selection.active_tool?.motion (content, transformed.x, transformed.y, transformed_backlog);

        invalidate_contents ();
    }

    public void commit_event (Graphene.Point point) {
        var transformed = viewport.widget_to_content_coords (point);
        tool_selection.active_tool?.commit (content, transformed.x, transformed.y);

        invalidate_contents ();
    }

    public async void export_pdf (File target_file) throws Error {
        var exporter = new PdfExporter (renderer, content);
        yield exporter.export (target_file);
    }
}
