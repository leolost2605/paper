/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Quicknote.PatternStyle : Object {
    public abstract string name { get; }

    public abstract void snapshot (
        float width, float height,
        Gdk.RGBA color,
        Gtk.Snapshot snapshot,
        Graphene.Rect bounds
    );
}
