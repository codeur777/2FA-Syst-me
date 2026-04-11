import { useState, useEffect } from 'react';

/**
 * Alert persistante avec disparition progressive après `duration` ms.
 * Se réinitialise à chaque changement de `message`.
 */
export default function Alert({ message, type = 'error', duration = 6000 }) {
  const [visible, setVisible] = useState(false);
  const [fading, setFading] = useState(false);

  useEffect(() => {
    if (!message) return;

    // Réinitialiser l'état à chaque nouveau message
    setFading(false);
    setVisible(true);

    // Début du fondu 1s avant la fin
    const fadeTimer = setTimeout(() => setFading(true), duration - 1000);
    // Masquer complètement
    const hideTimer = setTimeout(() => setVisible(false), duration);

    return () => {
      clearTimeout(fadeTimer);
      clearTimeout(hideTimer);
    };
  }, [message, duration]);

  if (!message || !visible) return null;

  return (
    <div className={`alert alert-${type} ${fading ? 'alert-fading' : 'alert-visible'}`}>
      <span className="alert-icon">{type === 'error' ? '⚠️' : '✅'}</span>
      <span>{message}</span>
      <button
        className="alert-close"
        onClick={() => setVisible(false)}
        aria-label="Fermer"
      >
        ×
      </button>
    </div>
  );
}
