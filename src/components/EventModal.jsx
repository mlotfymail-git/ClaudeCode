import { useState, useEffect } from 'react';
import Avatar from './Avatar';
import './EventModal.css';

const EVENT_COLORS = [
  '#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6',
  '#06b6d4', '#f97316', '#ec4899',
];

export default function EventModal({ event, contacts, onSave, onDelete, onClose, defaultDate }) {
  const isNew = !event;

  const [form, setForm] = useState({
    title: '',
    date: defaultDate || new Date().toISOString().split('T')[0],
    startTime: '09:00',
    endTime: '10:00',
    color: '#6366f1',
    description: '',
    participants: [],
    ...(event || {}),
  });

  useEffect(() => {
    const handler = (e) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  const toggleParticipant = (id) => {
    set('participants', form.participants.includes(id)
      ? form.participants.filter(p => p !== id)
      : [...form.participants, id]);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!form.title.trim()) return;
    onSave(form);
    onClose();
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-box" onClick={e => e.stopPropagation()}>
        <header className="modal-header" style={{ borderTop: `4px solid ${form.color}` }}>
          <h2>{isNew ? 'New Event' : 'Edit Event'}</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </header>

        <form onSubmit={handleSubmit} className="modal-form">
          {/* Title */}
          <div className="form-group">
            <label>Title *</label>
            <input
              required
              type="text"
              value={form.title}
              onChange={e => set('title', e.target.value)}
              placeholder="Event title"
              autoFocus
            />
          </div>

          {/* Date & Times */}
          <div className="form-row">
            <div className="form-group">
              <label>Date</label>
              <input type="date" value={form.date} onChange={e => set('date', e.target.value)} />
            </div>
            <div className="form-group">
              <label>Start</label>
              <input type="time" value={form.startTime} onChange={e => set('startTime', e.target.value)} />
            </div>
            <div className="form-group">
              <label>End</label>
              <input type="time" value={form.endTime} onChange={e => set('endTime', e.target.value)} />
            </div>
          </div>

          {/* Color */}
          <div className="form-group">
            <label>Color</label>
            <div className="color-picker">
              {EVENT_COLORS.map(c => (
                <button
                  key={c}
                  type="button"
                  className={`color-dot${form.color === c ? ' selected' : ''}`}
                  style={{ background: c }}
                  onClick={() => set('color', c)}
                />
              ))}
            </div>
          </div>

          {/* Description */}
          <div className="form-group">
            <label>Description</label>
            <textarea
              rows={3}
              value={form.description}
              onChange={e => set('description', e.target.value)}
              placeholder="Optional notes…"
            />
          </div>

          {/* Participants */}
          <div className="form-group">
            <label>Participants ({form.participants.length})</label>
            <div className="participants-grid">
              {contacts.map(c => {
                const active = form.participants.includes(c.id);
                return (
                  <button
                    key={c.id}
                    type="button"
                    className={`participant-chip${active ? ' active' : ''}`}
                    onClick={() => toggleParticipant(c.id)}
                  >
                    <Avatar contact={c} size={28} />
                    <span>{c.name.split(' ')[0]}</span>
                    {active && <span className="check">✓</span>}
                  </button>
                );
              })}
            </div>
          </div>

          <div className="modal-actions">
            {!isNew && (
              <button
                type="button"
                className="btn-danger"
                onClick={() => { onDelete(event.id); onClose(); }}
              >
                Delete
              </button>
            )}
            <div style={{ flex: 1 }} />
            <button type="button" className="btn-ghost" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary">
              {isNew ? 'Create Event' : 'Save Changes'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
