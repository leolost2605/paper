/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.DrawTarget : Gtk.Widget {
    public Renderer renderer { get; construct; }
    public Viewport viewport { get; construct; }

    private Content? _content;
    public Content? content {
        private get { return _content; }
        set {
            if (_content != null) {
                _content.changed.disconnect (queue_draw);
            }

            _content = value;

            if (_content != null) {
                _content.changed.connect (queue_draw);
            }

            queue_draw ();
        }
    }

    public DrawTarget (Renderer renderer, Viewport viewport) {
        Object (renderer: renderer, viewport: viewport);
    }

    construct {
        set_cursor (new Gdk.Cursor.from_name ("none", null));

        viewport.notify.connect (queue_draw);
    }

    public Graphene.Rect get_bounds () {
        Graphene.Rect bounds;
        compute_bounds (this, out bounds);
        return bounds;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        if (content == null) {
            return;
        }

        renderer.snapshot (content, viewport, snapshot, get_bounds ());
    }
}
