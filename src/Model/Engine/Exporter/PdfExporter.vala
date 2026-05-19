/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.PdfExporter : Exporter {
    public Renderer renderer { get; construct; }
    public Note note { get; construct; }

    public PdfExporter (Gtk.Window window, Renderer renderer, Note note) {
        Object (parent_window: window, renderer: renderer, note: note);
    }

    public async override void export () throws Error {
        var file = yield select_location (note.display_name + ".pdf");

        if (file == null) {
            return;
        }

        var pages = note.content.calculate_pages ();

        var page_size = pages[0].bounds.size;

        var surface = new Cairo.PdfSurface (file.get_path (), page_size.width, page_size.height);
        var context = new Cairo.Context (surface);

        foreach (var page in pages) {
            var snapshot = new Gtk.Snapshot ();

            renderer.snapshot_page (note.content, snapshot, page);
            var node = snapshot.to_node ();

            node.draw (context);

            context.show_page ();
        }

        surface.finish ();
    }
}
