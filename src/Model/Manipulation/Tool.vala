/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Quicknote.Tool : Object {
    public abstract void start (Content content);
    public abstract void add_point (Content content, float x, float y);
    public abstract void commit (Content content);
    public virtual void snapshot (Gtk.Snapshot snapshot) {}
}
