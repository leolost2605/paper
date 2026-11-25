/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.LibrarySidebarItem : Object {
    public string icon_name { get; construct; }
    public string name { get; construct; }
    public ListModel files { get; construct; }

    public LibrarySidebarItem (string icon_name, string name, ListModel files) {
        Object (icon_name: icon_name, name: name, files: files);
    }
}
