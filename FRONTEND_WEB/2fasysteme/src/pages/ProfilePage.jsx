import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api/axiosInstance';
import { useTheme } from '../context/ThemeContext';
import Alert from '../components/Alert';
import '../styles/profile.css';

const FAQ_ITEMS = [
  {
    q: "Qu'est-ce que la double authentification (2FA) ?",
    a: "La 2FA ajoute une couche de sécurité supplémentaire. En plus de votre mot de passe, un code à usage unique est envoyé à votre email à chaque connexion."
  },
  {
    q: "Comment désactiver la 2FA ?",
    a: "Dans la section Sécurité de votre profil, utilisez le bouton pour désactiver la double authentification. Attention, cela réduit la sécurité de votre compte."
  },
  {
    q: "Je ne reçois pas le code 2FA, que faire ?",
    a: "Vérifiez vos spams. Le code expire après 10 minutes. Vous pouvez en demander un nouveau depuis la page de vérification."
  },
  {
    q: "Comment changer mon mot de passe ?",
    a: "Dans la section Sécurité, entrez votre mot de passe actuel puis votre nouveau mot de passe (minimum 8 caractères)."
  },
  {
    q: "Mes données sont-elles sécurisées ?",
    a: "Oui. Les mots de passe sont chiffrés avec BCrypt. Les tokens JWT expirent après 24h. Toutes les communications sont sécurisées."
  },
];

export default function ProfilePage() {
  const navigate = useNavigate();
  const { theme, toggleTheme } = useTheme();
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState('profile');
  const [profileForm, setProfileForm] = useState({ firstName: '', lastName: '', phone: '' });
  const [passwordForm, setPasswordForm] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' });
  const [message, setMessage] = useState({ type: '', text: '' });
  const [loading, setLoading] = useState(false);
  const [openFaq, setOpenFaq] = useState(null);

  useEffect(() => {
    api.get('/user/profile')
      .then(res => {
        setUser(res.data);
        setProfileForm({
          firstName: res.data.firstName,
          lastName: res.data.lastName,
          phone: res.data.phone || '',
        });
      })
      .catch(() => navigate('/login'));
  }, [navigate]);

  const showMessage = (type, text) => {
    setMessage({ type, text });
  };

  const handleProfileSave = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.put('/user/profile', { ...profileForm, theme });
      setUser(data);
      showMessage('success', 'Profil mis à jour avec succès');
    } catch {
      showMessage('error', 'Erreur lors de la mise à jour');
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordChange = async (e) => {
    e.preventDefault();
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      showMessage('error', 'Les mots de passe ne correspondent pas');
      return;
    }
    setLoading(true);
    try {
      await api.put('/user/change-password', {
        currentPassword: passwordForm.currentPassword,
        newPassword: passwordForm.newPassword,
      });
      setPasswordForm({ currentPassword: '', newPassword: '', confirmPassword: '' });
      showMessage('success', 'Mot de passe modifié avec succès');
    } catch (err) {
      showMessage('error', err.response?.data?.error || 'Erreur lors du changement');
    } finally {
      setLoading(false);
    }
  };

  const handleToggle2FA = async () => {
    const newState = !user.twoFactorEnabled;
    try {
      const { data } = await api.patch(`/user/2fa?enabled=${newState}`);
      setUser(data);
      showMessage('success', `2FA ${newState ? 'activée' : 'désactivée'}`);
    } catch {
      showMessage('error', 'Erreur lors de la modification');
    }
  };

  const handleThemeToggle = async () => {
    toggleTheme();
    const newTheme = theme === 'light' ? 'dark' : 'light';
    try {
      await api.put('/user/profile', { theme: newTheme });
    } catch { /* silencieux */ }
  };

  const handleLogout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    navigate('/login');
  };

  if (!user) return <div className="loading-screen">Chargement...</div>;

  return (
    <div className="profile-page">
      <aside className="sidebar">
        <div className="sidebar-header">
          <div className="avatar">
            {user.firstName?.[0]}{user.lastName?.[0]}
          </div>
          <div className="user-info">
            <span className="user-name">{user.firstName} {user.lastName}</span>
            <span className="user-email">{user.email}</span>
          </div>
        </div>

        <nav className="sidebar-nav">
          {[
            { id: 'profile', icon: '👤', label: 'Profil' },
            { id: 'security', icon: '🔒', label: 'Sécurité' },
            { id: 'faq', icon: '❓', label: 'FAQ' },
          ].map(tab => (
            <button
              key={tab.id}
              className={`nav-item ${activeTab === tab.id ? 'active' : ''}`}
              onClick={() => setActiveTab(tab.id)}
            >
              <span>{tab.icon}</span> {tab.label}
            </button>
          ))}
        </nav>

        <div className="sidebar-footer">
          <button className="theme-toggle" onClick={handleThemeToggle} aria-label="Changer le thème">
            {theme === 'light' ? '🌙 Mode sombre' : '☀️ Mode clair'}
          </button>
          <button className="btn-logout" onClick={handleLogout}>
            🚪 Déconnexion
          </button>
        </div>
      </aside>

      <main className="profile-content">
        {message.text && (
          <Alert message={message.text} type={message.type} duration={6000} />
        )}

        {/* ── PROFIL ── */}
        {activeTab === 'profile' && (
          <section className="content-section">
            <h2>Informations personnelles</h2>
            <form onSubmit={handleProfileSave} className="profile-form">
              <div className="form-row">
                <div className="form-group">
                  <label>Prénom</label>
                  <input type="text" value={profileForm.firstName}
                    onChange={e => setProfileForm({ ...profileForm, firstName: e.target.value })} required />
                </div>
                <div className="form-group">
                  <label>Nom</label>
                  <input type="text" value={profileForm.lastName}
                    onChange={e => setProfileForm({ ...profileForm, lastName: e.target.value })} required />
                </div>
              </div>
              <div className="form-group">
                <label>Email</label>
                <input type="email" value={user.email} disabled className="input-disabled" />
              </div>
              <div className="form-group">
                <label>Téléphone</label>
                <input type="tel" value={profileForm.phone}
                  onChange={e => setProfileForm({ ...profileForm, phone: e.target.value })}
                  placeholder="+33 6 00 00 00 00" />
              </div>
              <div className="form-group">
                <label>Membre depuis</label>
                <input type="text" value={new Date(user.createdAt).toLocaleDateString('fr-FR')} disabled className="input-disabled" />
              </div>
              <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? 'Sauvegarde...' : 'Sauvegarder'}
              </button>
            </form>
          </section>
        )}

        {/* ── SÉCURITÉ ── */}
        {activeTab === 'security' && (
          <section className="content-section">
            <h2>Sécurité</h2>

            <div className="security-card">
              <div className="security-card-header">
                <div>
                  <h3>Double authentification (2FA)</h3>
                  <p>Un code est envoyé par email à chaque connexion</p>
                </div>
                <button
                  className={`toggle-btn ${user.twoFactorEnabled ? 'active' : ''}`}
                  onClick={handleToggle2FA}
                  aria-label="Activer/désactiver la 2FA"
                >
                  <span className="toggle-thumb" />
                </button>
              </div>
              <span className={`badge ${user.twoFactorEnabled ? 'badge-green' : 'badge-red'}`}>
                {user.twoFactorEnabled ? '✓ Activée' : '✗ Désactivée'}
              </span>
            </div>

            <div className="divider" />

            <h3>Changer le mot de passe</h3>
            <form onSubmit={handlePasswordChange} className="profile-form">
              <div className="form-group">
                <label>Mot de passe actuel</label>
                <input type="password" value={passwordForm.currentPassword}
                  onChange={e => setPasswordForm({ ...passwordForm, currentPassword: e.target.value })}
                  placeholder="••••••••" required autoComplete="current-password" />
              </div>
              <div className="form-group">
                <label>Nouveau mot de passe</label>
                <input type="password" value={passwordForm.newPassword}
                  onChange={e => setPasswordForm({ ...passwordForm, newPassword: e.target.value })}
                  placeholder="Min. 8 caractères" required autoComplete="new-password" />
              </div>
              <div className="form-group">
                <label>Confirmer le nouveau mot de passe</label>
                <input type="password" value={passwordForm.confirmPassword}
                  onChange={e => setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })}
                  placeholder="••••••••" required autoComplete="new-password" />
              </div>
              <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? 'Modification...' : 'Changer le mot de passe'}
              </button>
            </form>
          </section>
        )}

        {/* ── FAQ ── */}
        {activeTab === 'faq' && (
          <section className="content-section">
            <h2>Questions fréquentes</h2>
            <div className="faq-list">
              {FAQ_ITEMS.map((item, i) => (
                <div key={i} className={`faq-item ${openFaq === i ? 'open' : ''}`}>
                  <button className="faq-question" onClick={() => setOpenFaq(openFaq === i ? null : i)}>
                    <span>{item.q}</span>
                    <span className="faq-icon">{openFaq === i ? '−' : '+'}</span>
                  </button>
                  {openFaq === i && <p className="faq-answer">{item.a}</p>}
                </div>
              ))}
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
