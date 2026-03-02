/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.NoteFile : Object {
    public File file { get; construct; }
    public Note note { get; construct; }

    public NoteFile (File file) {
        Object (file: file);
    }

    construct {
        note = new Note ();

        Timeout.add_seconds (5, () => {
            save.begin ();
            return Source.CONTINUE;
        });
    }

    public async void load () throws Error {
        var json_parser = new Json.Parser ();

        var input_stream = yield file.read_async (Priority.DEFAULT, null);

        yield json_parser.load_from_stream_async (input_stream, null);

        new Parser ().parse_note (note, json_parser.get_root ().get_object ());
    }

    public async void save () throws Error {
        var node = new Parser ().build_note (note);

        var generator = new Json.Generator ();
        generator.set_root (node);

        var data = generator.to_data (null);

        yield file.replace_contents_async (data.data, null, true, NONE, null, null);
    }
}
