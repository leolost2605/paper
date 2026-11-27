/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * A list of files with associated meta data.
 * This can just be a directory or a special directory (e.g. home)
 * but also recent files, favorite files, etc.
 */
public class Paper.FileList : Object {
    public string name { get; construct; }
    public ListModel files { get; construct; }

    /**
     * If the files list represents a directory this is the URI of that directory.
     * Can be null, e.g. when the file list represents recently used files or favorites.
     */
    public string? uri { get; construct; }

    public string? icon_name { get; construct; }

    public FileList (string name, ListModel files, string? uri = null, string? icon_name = null) {
        Object (name: name, files: files, uri: uri, icon_name: icon_name);
    }
}
