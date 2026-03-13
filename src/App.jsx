import { useState } from 'react';
import { useStore } from './store';
import Calendar from './components/Calendar';
import Contacts from './components/Contacts';
import './App.css';

const TABS = [
  { id: 'calendar', label: 'Calendar', icon: '📅' },
  { id: 'contacts', label: 'Contacts', icon: '👥' },
];

export default function App() {
  const [tab, setTab] = useState('calendar');
  const [jumpDate, setJumpDate] = useState(null);

  const {
    contacts, addContact, updateContact, deleteContact,
    events,   addEvent,   updateEvent,   deleteEvent,
  } = useStore();

  const goToCalendar = (date) => {
    setJumpDate(date);
    setTab('calendar');
  };

  return (
    <div className="app">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <span className="brand-icon">📆</span>
          <span className="brand-name">CalSync</span>
        </div>

        <nav className="sidebar-nav">
          {TABS.map(t => (
            <button
              key={t.id}
              className={`nav-item${tab === t.id ? ' active' : ''}`}
              onClick={() => setTab(t.id)}
            >
              <span className="nav-icon">{t.icon}</span>
              <span>{t.label}</span>
            </button>
          ))}
        </nav>

        <div className="sidebar-stats">
          <div className="stat">
            <span className="stat-num">{events.length}</span>
            <span className="stat-lbl">Events</span>
          </div>
          <div className="stat">
            <span className="stat-num">{contacts.length}</span>
            <span className="stat-lbl">Contacts</span>
          </div>
        </div>
      </aside>

      <main className="main">
        <div className="main-header">
          <h1 className="page-title">
            {tab === 'calendar' ? '📅 Calendar' : '👥 Contacts'}
          </h1>
        </div>

        <div className="main-content">
          {tab === 'calendar' && (
            <Calendar
              events={events}
              contacts={contacts}
              onAdd={addEvent}
              onUpdate={updateEvent}
              onDelete={deleteEvent}
              jumpDate={jumpDate}
            />
          )}
          {tab === 'contacts' && (
            <Contacts
              contacts={contacts}
              events={events}
              onAddContact={addContact}
              onUpdateContact={updateContact}
              onDeleteContact={deleteContact}
              onAddEvent={addEvent}
              onUpdateEvent={updateEvent}
              onDeleteEvent={deleteEvent}
              onGoToCalendar={goToCalendar}
            />
          )}
        </div>
      </main>
    </div>
  );
}
