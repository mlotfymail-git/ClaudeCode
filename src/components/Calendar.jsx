import { useState } from 'react';
import EventModal from './EventModal';
import Avatar from './Avatar';
import './Calendar.css';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = [
  'January','February','March','April','May','June',
  'July','August','September','October','November','December',
];

function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

function startDay(year, month) {
  return new Date(year, month, 1).getDay();
}

export default function Calendar({ events, contacts, onAdd, onUpdate, onDelete }) {
  const now = new Date();
  const [year, setYear]     = useState(now.getFullYear());
  const [month, setMonth]   = useState(now.getMonth());
  const [modal, setModal]   = useState(null); // null | { event, defaultDate }
  const [hovered, setHovered] = useState(null);

  const prevMonth = () => {
    if (month === 0) { setMonth(11); setYear(y => y - 1); }
    else setMonth(m => m - 1);
  };
  const nextMonth = () => {
    if (month === 11) { setMonth(0); setYear(y => y + 1); }
    else setMonth(m => m + 1);
  };

  const totalDays = daysInMonth(year, month);
  const firstDay  = startDay(year, month);

  // map events by date
  const eventsByDate = {};
  events.forEach(e => {
    if (!eventsByDate[e.date]) eventsByDate[e.date] = [];
    eventsByDate[e.date].push(e);
  });

  const toDateStr = (d) =>
    `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;

  const todayStr = now.toISOString().split('T')[0];

  const openNew = (dateStr) => setModal({ event: null, defaultDate: dateStr });
  const openEdit = (e, ev) => { ev.stopPropagation(); setModal({ event: e, defaultDate: e.date }); };

  const handleSave = (form) => {
    if (modal.event) onUpdate(modal.event.id, form);
    else onAdd(form);
  };

  // Build cells
  const cells = [];
  for (let i = 0; i < firstDay; i++) cells.push(null);
  for (let d = 1; d <= totalDays; d++) cells.push(d);

  return (
    <div className="calendar-wrap">
      {/* toolbar */}
      <div className="cal-toolbar">
        <div className="cal-nav">
          <button className="cal-nav-btn" onClick={prevMonth}>‹</button>
          <h2 className="cal-title">{MONTHS[month]} {year}</h2>
          <button className="cal-nav-btn" onClick={nextMonth}>›</button>
        </div>
        <button className="btn-add-event" onClick={() => openNew(todayStr)}>
          + New Event
        </button>
      </div>

      {/* day headers */}
      <div className="cal-grid">
        {DAYS.map(d => (
          <div key={d} className="cal-day-header">{d}</div>
        ))}

        {cells.map((day, i) => {
          if (!day) return <div key={`e-${i}`} className="cal-cell empty" />;
          const dateStr = toDateStr(day);
          const dayEvents = eventsByDate[dateStr] || [];
          const isToday = dateStr === todayStr;
          return (
            <div
              key={dateStr}
              className={`cal-cell${isToday ? ' today' : ''}`}
              onClick={() => openNew(dateStr)}
            >
              <span className="cal-day-num">{day}</span>
              <div className="cal-events">
                {dayEvents.map(e => {
                  const parts = contacts.filter(c => e.participants.includes(c.id));
                  return (
                    <div
                      key={e.id}
                      className="cal-event-pill"
                      style={{ background: e.color + '22', borderLeft: `3px solid ${e.color}` }}
                      onClick={(ev) => openEdit(e, ev)}
                      onMouseEnter={() => setHovered(e.id)}
                      onMouseLeave={() => setHovered(null)}
                    >
                      <span className="pill-title" style={{ color: e.color }}>
                        {e.startTime} {e.title}
                      </span>
                      {parts.length > 0 && (
                        <div className="pill-avatars">
                          {parts.slice(0, 3).map(c => (
                            <Avatar key={c.id} contact={c} size={16} />
                          ))}
                          {parts.length > 3 && (
                            <span className="pill-more">+{parts.length - 3}</span>
                          )}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>

      {/* legend / upcoming */}
      <div className="cal-upcoming">
        <h3>Upcoming Events</h3>
        {events
          .filter(e => e.date >= todayStr)
          .sort((a, b) => a.date.localeCompare(b.date) || a.startTime.localeCompare(b.startTime))
          .slice(0, 6)
          .map(e => {
            const parts = contacts.filter(c => e.participants.includes(c.id));
            return (
              <div
                key={e.id}
                className="upcoming-row"
                onClick={(ev) => openEdit(e, ev)}
              >
                <div className="upcoming-bar" style={{ background: e.color }} />
                <div className="upcoming-info">
                  <div className="upcoming-title">{e.title}</div>
                  <div className="upcoming-meta">
                    {e.date} · {e.startTime}–{e.endTime}
                  </div>
                </div>
                <div className="upcoming-avatars">
                  {parts.slice(0, 4).map(c => (
                    <Avatar key={c.id} contact={c} size={24} />
                  ))}
                </div>
              </div>
            );
          })}
        {events.filter(e => e.date >= todayStr).length === 0 && (
          <p className="empty-state">No upcoming events.</p>
        )}
      </div>

      {modal && (
        <EventModal
          event={modal.event}
          contacts={contacts}
          defaultDate={modal.defaultDate}
          onSave={handleSave}
          onDelete={onDelete}
          onClose={() => setModal(null)}
        />
      )}
    </div>
  );
}
