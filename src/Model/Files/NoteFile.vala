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
        note = new Note ();
    }

    public async void load_note () throws Error {
        var json_parser = new Json.Parser ();

        var input_stream = yield file.read_async (Priority.DEFAULT, null);

        yield json_parser.load_from_stream_async (input_stream, null);

        new Parser ().parse_note (note, json_parser.get_root ().get_object ());
    }

    public async void save_note () throws Error {
        var node = new Parser ().build_note (note);

        var generator = new Json.Generator ();
        generator.set_root (node);

        var stream = yield file.replace_async (null, false, NONE, Priority.DEFAULT, null);

        generator.to_stream (stream, null);
    }
}
