import { useNavigate } from 'react-router';
import { motion } from 'motion/react';
import { Mail } from 'lucide-react';
import { Button } from '../components/ui/button';
import { useLanguage } from '../contexts/LanguageContext';
import { LanguageSwitcher } from '../components/LanguageSwitcher';

export default function WelcomeAuth() {
  const navigate = useNavigate();
  const { t } = useLanguage();

  return (
    <div className="min-h-screen w-full bg-gradient-to-b from-white to-[#FFF8E1] flex flex-col">
      {/* Language switcher */}
      <div className="absolute top-6 right-6">
        <LanguageSwitcher />
      </div>

      {/* Top section - Welcome */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex-1 flex flex-col items-center justify-center px-8 pt-20 pb-12"
      >
        <div className="text-center mb-8">
          <h1 className="text-4xl text-[#212121] mb-3">{t('welcome')}</h1>
          <p className="text-[#757575] text-base max-w-sm mx-auto">
            {t('welcome_subtitle')}
          </p>
        </div>

        {/* Illustration/Icon */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.2, type: "spring" }}
          className="mb-8"
        >
          <div className="w-32 h-32 rounded-full bg-[#2D8659]/10 flex items-center justify-center">
            <div className="text-6xl">🍽️</div>
          </div>
        </motion.div>
      </motion.div>

      {/* Bottom section - Auth buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="px-8 pb-12 space-y-4"
      >
        {/* Google */}
        <Button
          onClick={() => navigate('/signup')}
          className="w-full bg-white hover:bg-gray-50 text-gray-800 border border-gray-300 py-6 text-base rounded-xl shadow-sm transition-all active:scale-95 flex items-center justify-center gap-3"
        >
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
          {t('continue_google')}
        </Button>

        {/* Facebook */}
        <Button
          onClick={() => navigate('/signup')}
          className="w-full bg-[#1877F2] hover:bg-[#166fe5] text-white py-6 text-base rounded-xl shadow-sm transition-all active:scale-95 flex items-center justify-center gap-3"
        >
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
          </svg>
          {t('continue_facebook')}
        </Button>

        {/* Divider */}
        <div className="flex items-center gap-4 py-2">
          <div className="flex-1 h-px bg-gray-300" />
          <span className="text-gray-500 text-sm">{t('or')}</span>
          <div className="flex-1 h-px bg-gray-300" />
        </div>

        {/* Email */}
        <Button
          onClick={() => navigate('/signup')}
          variant="outline"
          className="w-full border-2 border-[#2D8659] text-[#2D8659] hover:bg-[#2D8659]/5 py-6 text-base rounded-xl transition-all active:scale-95 flex items-center justify-center gap-3"
        >
          <Mail className="w-5 h-5" />
          {t('continue_email')}
        </Button>

        {/* Terms */}
        <p className="text-xs text-center text-gray-500 pt-4 px-4">
          {t('terms_privacy')}
        </p>
s
        {/* Login link */}
        <div className="text-center pt-2">
          <button
            onClick={() => navigate('/login')}
            className="text-[#2D8659] text-sm hover:underline"
          >
            {t('already_have_account')} <span className="font-semibold">{t('login')}</span>
          </button>
        </div>
      </motion.div>

      {/* Algerian colors accent */}
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-[#2D8659] via-white to-[#D32F2F]" />
    </div>
  );
}