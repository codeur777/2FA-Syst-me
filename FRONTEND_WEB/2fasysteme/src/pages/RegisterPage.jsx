import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import PhoneInput from 'react-phone-input-2';
import 'react-phone-input-2/lib/style.css';
import api from '../api/axiosInstance';
import Alert from '../components/Alert';
import '../styles/auth.css';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    email: '', password: '', confirmPassword: '',
    firstName: '', lastName: '', phone: ''
  });
  const [phoneValue, setPhoneValue] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const passwordStrength = (pwd) => {
    if (!pwd) return null;
    if (pwd.length < 6) return { level: 1, label: 'Faible', color: '#ef4444' };
    if (pwd.length < 8 || !/[0-9]/.test(pwd)) return { level: 2, label: 'Moyen', color: '#f59e0b' };
    if (/[A-Z]/.test(pwd) && /[0-9]/.test(pwd) && pwd.length >= 8) return { level: 3, label: 'Fort', color: '#10b981' };
    return { level: 2, label: 'Moyen', color: '#f59e0b' };
  };

  const strength = passwordStrength(form.password);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (form.password !== form.confirmPassword) {
      setError('Les mots de passe ne correspondent pas');
      return;
    }
    setLoading(true);
    try {
      const { data } = await api.post('/auth/register', {
        email: form.email,
        password: form.password,
        firstName: form.firstName,
        lastName: form.lastName,
        phone: phoneValue ? `+${phoneValue}` : '',
      });
      navigate('/verify-2fa', { state: { email: data.email, fromRegister: true } });
    } catch (err) {
      setError(err.response?.data?.error || "Erreur lors de l'inscription");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card auth-card--wide">

        {/* Header */}
        <div className="auth-header">
          <div className="auth-logo">🔐</div>
          <h1 className="auth-title">Créer un compte</h1>
          <p className="auth-subtitle">Rejoignez 2FA Systeme — sécurisé dès le départ</p>
        </div>

        {error && <Alert message={error} type="error" duration={6000} />}

        <form onSubmit={handleSubmit} className="auth-form">

          {/* Étape 1 — Identité */}
          <div className="form-section-label">Informations personnelles</div>
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="firstName">Prénom <span className="required">*</span></label>
              <div className="input-wrapper">
                <span className="input-icon">👤</span>
                <input
                  id="firstName" type="text" name="firstName"
                  value={form.firstName} onChange={handleChange}
                  placeholder="Jean" required
                />
              </div>
            </div>
            <div className="form-group">
              <label htmlFor="lastName">Nom <span className="required">*</span></label>
              <div className="input-wrapper">
                <span className="input-icon">👤</span>
                <input
                  id="lastName" type="text" name="lastName"
                  value={form.lastName} onChange={handleChange}
                  placeholder="Dupont" required
                />
              </div>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="email">Email <span className="required">*</span></label>
              <div className="input-wrapper">
                <span className="input-icon">✉️</span>
                <input
                  id="email" type="email" name="email"
                  value={form.email} onChange={handleChange}
                  placeholder="vous@exemple.com" required autoComplete="email"
                />
              </div>
            </div>
            <div className="form-group">
              <label htmlFor="phone">Téléphone <span className="optional">(optionnel)</span></label>
              <PhoneInput
                country={'fr'}
                value={phoneValue}
                onChange={setPhoneValue}
                inputProps={{ id: 'phone', name: 'phone' }}
                enableSearch
                searchPlaceholder="Rechercher un pays..."
                specialLabel=""
                containerStyle={{ width: '100%' }}
                inputStyle={{ width: '100%', height: '42px', fontSize: '14px' }}
              />
            </div>
          </div>

          {/* Étape 2 — Sécurité */}
          <div className="form-section-label" style={{ marginTop: '0.5rem' }}>Sécurité</div>
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="password">Mot de passe <span className="required">*</span></label>
              <div className="input-wrapper">
                <span className="input-icon">🔒</span>
                <input
                  id="password" type={showPassword ? 'text' : 'password'}
                  name="password" value={form.password} onChange={handleChange}
                  placeholder="Min. 8 caractères" required autoComplete="new-password"
                />
                <button
                  type="button" className="input-toggle"
                  onClick={() => setShowPassword(v => !v)}
                  aria-label="Afficher/masquer le mot de passe"
                >
                  {showPassword ? '🙈' : '👁️'}
                </button>
              </div>
              {strength && (
                <div className="password-strength">
                  <div className="strength-bar">
                    {[1, 2, 3].map(i => (
                      <div
                        key={i}
                        className="strength-segment"
                        style={{ background: i <= strength.level ? strength.color : 'var(--border)' }}
                      />
                    ))}
                  </div>
                  <span className="strength-label" style={{ color: strength.color }}>
                    {strength.label}
                  </span>
                </div>
              )}
            </div>
            <div className="form-group">
              <label htmlFor="confirmPassword">Confirmer <span className="required">*</span></label>
              <div className="input-wrapper">
                <span className="input-icon">🔒</span>
                <input
                  id="confirmPassword" type={showConfirm ? 'text' : 'password'}
                  name="confirmPassword" value={form.confirmPassword} onChange={handleChange}
                  placeholder="••••••••" required autoComplete="new-password"
                />
                <button
                  type="button" className="input-toggle"
                  onClick={() => setShowConfirm(v => !v)}
                  aria-label="Afficher/masquer la confirmation"
                >
                  {showConfirm ? '🙈' : '👁️'}
                </button>
              </div>
              {form.confirmPassword && (
                <span className={`match-hint ${form.password === form.confirmPassword ? 'match-ok' : 'match-no'}`}>
                  {form.password === form.confirmPassword ? '✓ Correspond' : '✗ Ne correspond pas'}
                </span>
              )}
            </div>
          </div>

          {/* Info 2FA */}
          <div className="info-banner">
            🛡️ Un code de vérification sera envoyé à votre email pour activer la double authentification.
          </div>

          <button type="submit" className="btn-primary" disabled={loading}>
            {loading
              ? <span className="btn-loading"><span className="spinner" /> Création en cours...</span>
              : 'Créer mon compte'}
          </button>
        </form>

        <p className="auth-switch">
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
      </div>
    </div>
  );
}
