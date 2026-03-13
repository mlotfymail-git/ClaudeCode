import { useState, useEffect } from 'react';
import Avatar from './Avatar';
import './EventModal.css';
import './ContactModal.css';

const COLORS = [
  '#6366f1','#10b981','#f59e0b','#ef4444','#8b5cf6',
  '#06b6d4','#f97316','#ec4899','#0ea5e9','#84cc16',
];

export default function ContactModal({ contact, onSave, onDelete, onClose }) {
  const isNew = !contact;
  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    avatar: null,
    color: '#6366f1',
    ...(contact || {}),
  });

  useEffect(() => {
    const handler = (e) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  const handlePhoto = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => set('avatar', ev.target.result);
    reader.readAsDataURL(file);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!form.name.trim()) return;
    onSave(form);
    onClose();
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-box" onClick={e => e.stopPropagation()}>
        <header className="modal-header" style={{ borderTop: `4px solid ${form.color}` }}>
          <h2>{isNew ? 'New Contact' : 'Edit Contact'}</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </header>

        <form onSubmit={handleSubmit} className="modal-form">
          {/* Avatar picker */}
          <div className="contact-avatar-row">
            <Avatar contact={form} size={72} />
            <div className="avatar-actions">
              <label className="btn-upload">
                Upload Photo
                <input type="file" accept="image/*" onChange={handlePhoto} hidden />
              </label>
              {form.avatar && (
                <button type="button" className="btn-ghost-sm" onClick={() => set('avatar', null)}>
                  Remove
                </button>
              )}
            </div>
          </div>

          {/* Color */}
          <div className="form-group">
            <label>Avatar Color</label>
            <div className="color-picker">
              {COLORS.map(c => (
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

          <div className="form-group">
            <label>Full Name *</label>
            <input required type="text" value={form.name} onChange={e => set('name', e.target.value)} placeholder="Jane Doe" autoFocus />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Email</label>
              <input type="email" value={form.email} onChange={e => set('email', e.target.value)} placeholder="jane@example.com" />
            </div>
            <div className="form-group">
              <label>Phone</label>
              <input type="tel" value={form.phone} onChange={e => set('phone', e.target.value)} placeholder="+1 555-0100" />
            </div>
          </div>

          <div className="form-group">
            <label>Role / Title</label>
            <input type="text" value={form.role} onChange={e => set('role', e.target.value)} placeholder="e.g. Product Manager" />
          </div>

          <div className="modal-actions">
            {!isNew && (
              <button type="button" className="btn-danger" onClick={() => { onDelete(contact.id); onClose(); }}>
                Delete
              </button>
            )}
            <div style={{ flex: 1 }} />
            <button type="button" className="btn-ghost" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary">{isNew ? 'Add Contact' : 'Save'}</button>
          </div>
        </form>
      </div>
    </div>
  );
}
