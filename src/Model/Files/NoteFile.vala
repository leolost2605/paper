/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.NoteFile : FileBase {
    public Note note { get; private set; }

    public NoteFile (File file, FileInfo info) {
        Object (file: file, info: info);
    }

    construct {
        var database = new Database (file.get_path ());
        note = new Note (database);
    }
}
