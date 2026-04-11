import { useState, useRef, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import api from '../api/axiosInstance';
import { useAuth } from '../context/AuthContext';
import Alert from '../components/Alert';
import '../styles/auth.css';

export default function Verify2FAPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuth();
  const email = location.state?.email;
  const [digits, setDigits] = useState(['', '', '', '', '', '']);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [resendCooldown, setResendCooldown] = useState(0);
  const inputs = useRef([]);

  useEffect(() => {
    if (!email) navigate('/login');
    inputs.current[0]?.focus();
  }, [email, navigate]);

  useEffect(() => {
    if (resendCooldown > 0) {
      const t = setTimeout(() => setResendCooldown(c => c - 1), 1000);
      return () => clearTimeout(t);
    }
  }, [resendCooldown]);

  const handleDigitChange = (index, value) => {
    if (!/^\d?$/.test(value)) return;
    const newDigits = [...digits];
    newDigits[index] = value;
    setDigits(newDigits);
    if (value && index < 5) inputs.current[index + 1]?.focus();
  };

  const handleKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      inputs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e) => {
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (pasted.length === 6) {
      setDigits(pasted.split(''));
      inputs.current[5]?.focus();
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const code = digits.join('');
    if (code.length < 6) { setError('Entrez les 6 chiffres'); return; }
    setError('');
    setLoading(true);
    try {
      const { data } = await api.post('/auth/verify-2fa', { email, code });
      // Stocker les tokens d'abord
      localStorage.setItem('accessToken', data.accessToken);
      localStorage.setItem('refreshToken', data.refreshToken);
      // Charger le profil et mettre à jour le contexte
      const profileRes = await api.get('/user/profile');
      login({ accessToken: data.accessToken, refreshToken: data.refreshToken }, profileRes.data);
      navigate('/profile');
    } catch (err) {
      setError(err.response?.data?.error || 'Code invalide');
      setDigits(['', '', '', '', '', '']);
      inputs.current[0]?.focus();
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (resendCooldown > 0) return;
    setResendCooldown(60);
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-logo">📧</div>
        <h1 className="auth-title">Vérification 2FA</h1>
        <p className="auth-subtitle">
          Code envoyé à <strong>{email}</strong>
        </p>

        {error && <Alert message={error} type="error" duration={6000} />}

        <form onSubmit={handleSubmit} className="auth-form">
          <div className="otp-inputs" onPaste={handlePaste}>
            {digits.map((d, i) => (
              <input
                key={i}
                ref={el => inputs.current[i] = el}
                type="text"
                inputMode="numeric"
                maxLength={1}
                value={d}
                onChange={e => handleDigitChange(i, e.target.value)}
                onKeyDown={e => handleKeyDown(i, e)}
                className="otp-input"
                aria-label={`Chiffre ${i + 1}`}
              />
            ))}
          </div>

          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Vérification...' : 'Vérifier'}
          </button>
        </form>

        <p className="auth-switch">
          Pas reçu le code ?{' '}
          <button className="btn-link" onClick={handleResend} disabled={resendCooldown > 0}>
            {resendCooldown > 0 ? `Renvoyer (${resendCooldown}s)` : 'Renvoyer'}
          </button>
        </p>

        <p className="auth-switch">
          <button className="btn-link" onClick={() => navigate('/login')}>
            ← Retour à la connexion
          </button>
        </p>
      </div>
    </div>
  );
}
