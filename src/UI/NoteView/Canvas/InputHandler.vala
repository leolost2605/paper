/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.InputHandler : Object {
    public Gtk.Widget target { get; construct; }
    public Viewport viewport { get; construct; }
    public Manipulator manipulator { get; construct; }

    private bool is_drawing = false;

    public InputHandler (Gtk.Widget target, Viewport viewport, Manipulator manipulator) {
        Object (target: target, viewport: viewport, manipulator: manipulator);
    }

    construct {
        var controller = new Gtk.EventControllerLegacy ();
        controller.event.connect (on_event);
        target.add_controller (controller);
    }

    private bool on_event (Gdk.Event event) {
        switch (event.get_event_type ()) {
            case Gdk.EventType.BUTTON_PRESS:
                is_drawing = true;
                manipulator.start ();
                break;

            case Gdk.EventType.BUTTON_RELEASE:
                is_drawing = false;
                manipulator.commit ();
                break;

            case Gdk.EventType.MOTION_NOTIFY:
                if (is_drawing) {
                    double surface_x, surface_y;
                    event.get_position (out surface_x, out surface_y);

                    var root = target.get_root ();
                    double transform_x, transform_y;
                    root.get_surface_transform (out transform_x, out transform_y);

                    var root_point = Graphene.Point () {
                        x = (float) (surface_x - transform_x),
                        y = (float) (surface_y - transform_y),
                    };

                    Graphene.Point widget_point;
                    root.compute_point (target, root_point, out widget_point);

                    var note_point = viewport.get_transform ().invert ().transform_point (widget_point);
                    manipulator.add_point (note_point.x, note_point.y);
                    target.queue_draw ();
                    return true;
                }

                break;

            default:
                break;
        }

        return false;
    }
}
