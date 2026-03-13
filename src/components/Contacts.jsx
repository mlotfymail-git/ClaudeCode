import { useState } from 'react';
import Avatar from './Avatar';
import ContactModal from './ContactModal';
import EventModal from './EventModal';
import './Contacts.css';

export default function Contacts({ contacts, events, onAddContact, onUpdateContact, onDeleteContact, onUpdateEvent, onAddEvent, onDeleteEvent, onGoToCalendar }) {
  const [search, setSearch]     = useState('');
  const [editContact, setEditContact] = useState(null);  // false=closed, null=new, obj=edit
  const [showNewContact, setShowNewContact] = useState(false);
  const [editEvent, setEditEvent] = useState(null);
  const [expandedId, setExpandedId] = useState(null);

  const filtered = contacts.filter(c =>
    c.name.toLowerCase().includes(search.toLowerCase()) ||
    c.email.toLowerCase().includes(search.toLowerCase()) ||
    c.role.toLowerCase().includes(search.toLowerCase())
  );

  const eventsForContact = (cid) =>
    events.filter(e => e.participants.includes(cid))
      .sort((a, b) => a.date.localeCompare(b.date));

  const today = new Date().toISOString().split('T')[0];

  const handleEventSave = (form) => {
    if (editEvent?.id) onUpdateEvent(editEvent.id, form);
    else onAddEvent(form);
  };

  return (
    <div className="contacts-wrap">
      <div className="contacts-toolbar">
        <input
          className="contacts-search"
          type="text"
          placeholder="Search contacts…"
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
        <button className="btn-add-contact" onClick={() => setShowNewContact(true)}>
          + New Contact
        </button>
      </div>

      <div className="contacts-count">{filtered.length} contact{filtered.length !== 1 ? 's' : ''}</div>

      <div className="contacts-grid">
        {filtered.map(c => {
          const cEvents = eventsForContact(c.id);
          const upcoming = cEvents.filter(e => e.date >= today);
          const past     = cEvents.filter(e => e.date < today);
          const isExpanded = expandedId === c.id;

          return (
            <div key={c.id} className={`contact-card${isExpanded ? ' expanded' : ''}`}>
              {/* Card header */}
              <div className="card-header" style={{ background: `${c.color}18` }}>
                <div className="card-banner" style={{ background: c.color }} />
                <div className="card-avatar-wrap">
                  <Avatar contact={c} size={64} />
                </div>
                <div className="card-actions">
                  <button className="card-btn" title="Edit contact" onClick={() => setEditContact(c)}>✏️</button>
                </div>
              </div>

              {/* Card body */}
              <div className="card-body">
                <h3 className="card-name">{c.name}</h3>
                {c.role && <p className="card-role">{c.role}</p>}

                <div className="card-details">
                  {c.email && (
                    <a href={`mailto:${c.email}`} className="card-detail">
                      <span className="detail-icon">✉</span> {c.email}
                    </a>
                  )}
                  {c.phone && (
                    <a href={`tel:${c.phone}`} className="card-detail">
                      <span className="detail-icon">📞</span> {c.phone}
                    </a>
                  )}
                </div>

                {/* Events summary */}
                <div className="card-events-summary">
                  <div className="events-badges">
                    <span className="badge badge-upcoming">{upcoming.length} upcoming</span>
                    <span className="badge badge-past">{past.length} past</span>
                  </div>
                  <button
                    className="btn-toggle-events"
                    onClick={() => setExpandedId(isExpanded ? null : c.id)}
                  >
                    {isExpanded ? 'Hide events ▲' : 'Show events ▼'}
                  </button>
                </div>

                {/* Expanded events list */}
                {isExpanded && (
                  <div className="card-events-list">
                    {cEvents.length === 0 && (
                      <p className="no-events">No events linked yet.</p>
                    )}
                    {cEvents.map(e => (
                      <div
                        key={e.id}
                        className={`event-link${e.date < today ? ' past' : ''}`}
                        onClick={() => setEditEvent(e)}
                      >
                        <div className="event-link-bar" style={{ background: e.color }} />
                        <div className="event-link-info">
                          <span className="event-link-title">{e.title}</span>
                          <span className="event-link-meta">{e.date} · {e.startTime}</span>
                        </div>
                        <div className="event-link-participants">
                          {contacts
                            .filter(p => e.participants.includes(p.id) && p.id !== c.id)
                            .slice(0, 3)
                            .map(p => <Avatar key={p.id} contact={p} size={18} />)}
                        </div>
                        <button
                          className="event-cal-btn"
                          title="Go to calendar"
                          onClick={(ev) => { ev.stopPropagation(); onGoToCalendar(e.date); }}
                        >
                          📅
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          );
        })}

        {filtered.length === 0 && (
          <div className="contacts-empty">No contacts found.</div>
        )}
      </div>

      {showNewContact && (
        <ContactModal
          contact={null}
          onSave={onAddContact}
          onDelete={() => {}}
          onClose={() => setShowNewContact(false)}
        />
      )}

      {editContact && (
        <ContactModal
          contact={editContact}
          onSave={(data) => onUpdateContact(editContact.id, data)}
          onDelete={onDeleteContact}
          onClose={() => setEditContact(null)}
        />
      )}

      {editEvent && (
        <EventModal
          event={editEvent}
          contacts={contacts}
          defaultDate={editEvent.date}
          onSave={handleEventSave}
          onDelete={onDeleteEvent}
          onClose={() => setEditEvent(null)}
        />
      )}
    </div>
  );
}
