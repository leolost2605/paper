/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Quicknote.ViewMode : Object {
    public abstract void push_clip (Gtk.Snapshot snapshot, Graphene.Rect bounds);
    public abstract void pop_clip (Gtk.Snapshot snapshot);
    //TODO: Something like get_max_scroll (Gtk.DirectionType direction);
}
