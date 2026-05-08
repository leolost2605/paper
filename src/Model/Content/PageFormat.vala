/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Quicknote.PageFormat : Object {
    public abstract void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds);
    public abstract Graphene.Size get_size ();
}
