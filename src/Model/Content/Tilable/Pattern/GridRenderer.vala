/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.GridRenderer : Paper.PatternRenderer {
    public override string name { get { return _("Grid"); } }

    private Gsk.Stroke stroke = new Gsk.Stroke (0.5f);

    public override void snapshot (
        float width, float height,
        Gdk.RGBA color,
        Gtk.Snapshot snapshot,
        int n
    ) {
        /* Vertical lines */
        for (int i = 0; i < n; i++) {
            var path_builder = new Gsk.PathBuilder ();
            /* We offset half the width of the stroke to make sure we are fully in our tile */
            path_builder.move_to (width * i + 0.25f, 0);
            path_builder.line_to (width * i + 0.25f, height * n);

            var path = path_builder.to_path ();
            snapshot.append_stroke (path, stroke, color);
        }

        /* Horizontal lines */
        for (int i = 0; i < n; i++) {
            var path_builder = new Gsk.PathBuilder ();
            path_builder.move_to (0, height * i + 0.25f);
            path_builder.line_to (width * n, height * i + 0.25f);

            var path = path_builder.to_path ();
            snapshot.append_stroke (path, stroke, color);
        }
    }
}
