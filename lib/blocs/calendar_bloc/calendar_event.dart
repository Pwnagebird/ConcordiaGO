part of 'calendar_bloc.dart';

@immutable
abstract class CalendarEvent {
  const CalendarEvent();

  CalendarState createState();
}

class GetClass extends CalendarEvent {
  const GetClass(this.event);

  final Event event;

  @override
  CalendarState createState() {
    return ClassInfo(event.title, event.location, event.start, event.end);
  }
}