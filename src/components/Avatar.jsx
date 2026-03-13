export default function Avatar({ contact, size = 40 }) {
  const initials = contact.name
    .split(' ')
    .map(n => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();

  const style = {
    width: size,
    height: size,
    borderRadius: '50%',
    backgroundColor: contact.color || '#6366f1',
    color: '#fff',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 700,
    fontSize: size * 0.38,
    flexShrink: 0,
    overflow: 'hidden',
  };

  if (contact.avatar) {
    return (
      <div style={style}>
        <img
          src={contact.avatar}
          alt={contact.name}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      </div>
    );
  }

  return <div style={style}>{initials}</div>;
}
