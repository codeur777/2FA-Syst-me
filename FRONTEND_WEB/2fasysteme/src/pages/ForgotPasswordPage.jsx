import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/axiosInstance';
import '../styles/auth.css';

export default function ForgotPasswordPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1); // 1: email, 2: code + nouveau mdp
  const [email, setEmail] = useState('');
  const [form, setForm] = useState({ code: '', newPassword: '', confirmPassword: '' });
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSendCode = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await api.post('/auth/forgot-password', { email });
      setMessage('Si cet email existe, un code a été envoyé.');
      setStep(2);
    } catch {
      setError('Une erreur est survenue');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = async (e) => {
    e.preventDefault();
    setError('');
    if (form.newPassword !== form.confirmPassword) {
      setError('Les mots de passe ne correspondent pas');
      return;
    }
    setLoading(true);
    try {
      await api.post('/auth/reset-password', {
        email,
        code: form.code,
        newPassword: form.newPassword,
      });
      navigate('/login', { state: { message: 'Mot de passe réinitialisé avec succès !' } });
    } catch (err) {
      setError(err.response?.data?.error || 'Code invalide ou expiré');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-logo">🔑</div>
        <h1 className="auth-title">Mot de passe oublié</h1>

        {message && <div className="alert alert-success">{message}</div>}
        {error && <div className="alert alert-error">{error}</div>}

        {step === 1 ? (
          <form onSubmit={handleSendCode} className="auth-form">
            <p className="auth-subtitle">Entrez votre email pour recevoir un code de réinitialisation.</p>
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="vous@exemple.com"
                required
              />
            </div>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Envoi...' : 'Envoyer le code'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleReset} className="auth-form">
            <p className="auth-subtitle">Entrez le code reçu et votre nouveau mot de passe.</p>
            <div className="form-group">
              <label htmlFor="code">Code de vérification</label>
              <input
                id="code"
                type="text"
                inputMode="numeric"
                maxLength={6}
                value={form.code}
                onChange={e => setForm({ ...form, code: e.target.value })}
                placeholder="123456"
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="newPassword">Nouveau mot de passe</label>
              <input
                id="newPassword"
                type="password"
                value={form.newPassword}
                onChange={e => setForm({ ...form, newPassword: e.target.value })}
                placeholder="Min. 8 caractères"
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="confirmPassword">Confirmer le mot de passe</label>
              <input
                id="confirmPassword"
                type="password"
                value={form.confirmPassword}
                onChange={e => setForm({ ...form, confirmPassword: e.target.value })}
                placeholder="••••••••"
                required
              />
            </div>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Réinitialisation...' : 'Réinitialiser'}
            </button>
          </form>
        )}

        <p className="auth-switch">
          <Link to="/login">← Retour à la connexion</Link>
        </p>
      </div>
    </div>
  );
}
