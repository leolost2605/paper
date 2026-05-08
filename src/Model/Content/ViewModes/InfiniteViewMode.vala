/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.InfiniteViewMode : ViewMode {
    public override void push_clip (Gtk.Snapshot snapshot, Graphene.Rect bounds, PageFormat? page_format) {
        /* We don't want to clip anything in infinite view mode so no op */
    }

    public override void pop_clip (Gtk.Snapshot snapshot) {
        /* We didn't clip anything so nothing to pop */
    }
}
