import { useState, useCallback } from 'react';

// ── seed data ──────────────────────────────────────────────────────────────
const SEED_CONTACTS = [
  {
    id: 'c1',
    name: 'Alice Johnson',
    email: 'alice@example.com',
    phone: '+1 555-0101',
    role: 'Product Manager',
    avatar: null,
    color: '#6366f1',
  },
  {
    id: 'c2',
    name: 'Bob Martinez',
    email: 'bob@example.com',
    phone: '+1 555-0102',
    role: 'Frontend Dev',
    avatar: null,
    color: '#10b981',
  },
  {
    id: 'c3',
    name: 'Carol White',
    email: 'carol@example.com',
    phone: '+1 555-0103',
    role: 'Designer',
    avatar: null,
    color: '#f59e0b',
  },
  {
    id: 'c4',
    name: 'David Lee',
    email: 'david@example.com',
    phone: '+1 555-0104',
    role: 'Backend Dev',
    avatar: null,
    color: '#ef4444',
  },
  {
    id: 'c5',
    name: 'Eva Kim',
    email: 'eva@example.com',
    phone: '+1 555-0105',
    role: 'QA Engineer',
    avatar: null,
    color: '#8b5cf6',
  },
];

const today = new Date();
const y = today.getFullYear();
const m = today.getMonth();

const SEED_EVENTS = [
  {
    id: 'e1',
    title: 'Sprint Planning',
    date: new Date(y, m, 10).toISOString().split('T')[0],
    startTime: '09:00',
    endTime: '10:30',
    color: '#6366f1',
    description: 'Plan tasks for the upcoming sprint.',
    participants: ['c1', 'c2', 'c4'],
  },
  {
    id: 'e2',
    title: 'Design Review',
    date: new Date(y, m, 14).toISOString().split('T')[0],
    startTime: '14:00',
    endTime: '15:00',
    color: '#f59e0b',
    description: 'Review latest UI mockups with the team.',
    participants: ['c1', 'c3'],
  },
  {
    id: 'e3',
    title: 'QA Sync',
    date: new Date(y, m, 18).toISOString().split('T')[0],
    startTime: '11:00',
    endTime: '11:30',
    color: '#8b5cf6',
    description: 'Sync on open bugs and test coverage.',
    participants: ['c4', 'c5'],
  },
  {
    id: 'e4',
    title: 'All-Hands Meeting',
    date: new Date(y, m, 22).toISOString().split('T')[0],
    startTime: '10:00',
    endTime: '11:00',
    color: '#10b981',
    description: 'Company-wide monthly update.',
    participants: ['c1', 'c2', 'c3', 'c4', 'c5'],
  },
];

// ── helpers ────────────────────────────────────────────────────────────────
function uid() {
  return Math.random().toString(36).slice(2, 10);
}

function load(key, fallback) {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function save(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

// ── hook ───────────────────────────────────────────────────────────────────
export function useStore() {
  const [contacts, setContacts] = useState(() => load('cal_contacts', SEED_CONTACTS));
  const [events, setEvents] = useState(() => load('cal_events', SEED_EVENTS));

  // ── contacts ──
  const addContact = useCallback((data) => {
    const next = [...contacts, { ...data, id: uid() }];
    setContacts(next);
    save('cal_contacts', next);
  }, [contacts]);

  const updateContact = useCallback((id, data) => {
    const next = contacts.map(c => c.id === id ? { ...c, ...data } : c);
    setContacts(next);
    save('cal_contacts', next);
  }, [contacts]);

  const deleteContact = useCallback((id) => {
    const next = contacts.filter(c => c.id !== id);
    setContacts(next);
    save('cal_contacts', next);
    // remove from events too
    const evNext = events.map(e => ({
      ...e,
      participants: e.participants.filter(p => p !== id),
    }));
    setEvents(evNext);
    save('cal_events', evNext);
  }, [contacts, events]);

  // ── events ──
  const addEvent = useCallback((data) => {
    const next = [...events, { ...data, id: uid() }];
    setEvents(next);
    save('cal_events', next);
  }, [events]);

  const updateEvent = useCallback((id, data) => {
    const next = events.map(e => e.id === id ? { ...e, ...data } : e);
    setEvents(next);
    save('cal_events', next);
  }, [events]);

  const deleteEvent = useCallback((id) => {
    const next = events.filter(e => e.id !== id);
    setEvents(next);
    save('cal_events', next);
  }, [events]);

  return {
    contacts, addContact, updateContact, deleteContact,
    events, addEvent, updateEvent, deleteEvent,
  };
}
