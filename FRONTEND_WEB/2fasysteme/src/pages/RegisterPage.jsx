import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/axiosInstance';
import '../styles/auth.css';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    email: '', password: '', confirmPassword: '',
    firstName: '', lastName: '', phone: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

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
        phone: form.phone,
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
      <div className="auth-card">
        <div className="auth-logo">🔐</div>
        <h1 className="auth-title">Créer un compte</h1>
        <p className="auth-subtitle">Rejoignez 2FA Systeme</p>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleSubmit} className="auth-form">
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="firstName">Prénom</label>
              <input id="firstName" type="text" name="firstName" value={form.firstName}
                onChange={handleChange} placeholder="Jean" required />
            </div>
            <div className="form-group">
              <label htmlFor="lastName">Nom</label>
              <input id="lastName" type="text" name="lastName" value={form.lastName}
                onChange={handleChange} placeholder="Dupont" required />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input id="email" type="email" name="email" value={form.email}
              onChange={handleChange} placeholder="vous@exemple.com" required autoComplete="email" />
          </div>

          <div className="form-group">
            <label htmlFor="phone">Téléphone (optionnel)</label>
            <input id="phone" type="tel" name="phone" value={form.phone}
              onChange={handleChange} placeholder="+33 6 00 00 00 00" />
          </div>

          <div className="form-group">
            <label htmlFor="password">Mot de passe</label>
            <input id="password" type="password" name="password" value={form.password}
              onChange={handleChange} placeholder="Min. 8 caractères" required autoComplete="new-password" />
          </div>

          <div className="form-group">
            <label htmlFor="confirmPassword">Confirmer le mot de passe</label>
            <input id="confirmPassword" type="password" name="confirmPassword" value={form.confirmPassword}
              onChange={handleChange} placeholder="••••••••" required autoComplete="new-password" />
          </div>

          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Création...' : 'Créer mon compte'}
          </button>
        </form>

        <p className="auth-switch">
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
      </div>
    </div>
  );
}
