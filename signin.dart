import { useState } from 'react';
import { useNavigate } from 'react-router';
import { motion, AnimatePresence } from 'motion/react';
import { ArrowLeft, Eye, EyeOff, ShoppingBag, Store, Heart, X } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Checkbox } from '../components/ui/checkbox';
import { useLanguage } from '../contexts/LanguageContext';

type UserRole = 'consumer' | 'merchant' | 'charity' | null;

export default function SignUp() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  const [showRoleModal, setShowRoleModal] = useState(true);
  const [selectedRole, setSelectedRole] = useState<UserRole>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [agreedToTerms, setAgreedToTerms] = useState(false);
  const [sendUpdates, setSendUpdates] = useState(false);

  // Consumer fields
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');

  // Business fields
  const [businessName, setBusinessName] = useState('');
  const [businessType, setBusinessType] = useState('bakery');
  const [businessAddress, setBusinessAddress] = useState('');
  const [businessPhone, setBusinessPhone] = useState('');
  const [contactName, setContactName] = useState('');
  const [contactEmail, setContactEmail] = useState('');
  const [contactPassword, setContactPassword] = useState('');

  // Charity fields
  const [orgName, setOrgName] = useState('');
  const [regNumber, setRegNumber] = useState('');
  const [orgAddress, setOrgAddress] = useState('');
  const [contactPerson, setContactPerson] = useState('');
  const [position, setPosition] = useState('');
  const [orgEmail, setOrgEmail] = useState('');
  const [orgPhone, setOrgPhone] = useState('');
  const [orgPassword, setOrgPassword] = useState('');

  const getPasswordStrength = (pwd: string) => {
    if (pwd.length < 8) return { label: t('weak'), color: 'bg-red-500', width: '33%' };
    if (pwd.length < 12) return { label: t('medium'), color: 'bg-yellow-500', width: '66%' };
    return { label: t('strong'), color: 'bg-green-500', width: '100%' };
  };

  const getCurrentPassword = () => {
    if (selectedRole === 'merchant') return contactPassword;
    if (selectedRole === 'charity') return orgPassword;
    return password;
  };

  const strength = getCurrentPassword() ? getPasswordStrength(getCurrentPassword()) : null;

  const handleRoleSelect = (role: UserRole) => {
    setSelectedRole(role);
    setShowRoleModal(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (selectedRole === 'consumer') {
      navigate('/dashboard/consumer');
    } else if (selectedRole === 'merchant') {
      navigate('/dashboard/merchant');
    } else if (selectedRole === 'charity') {
      navigate('/dashboard/charity');
    }
  };

  return (
    <div className="min-h-screen w-full bg-white flex flex-col">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-100 px-6 py-4 flex items-center gap-4 z-10">
        <button
          onClick={() => navigate(-1)}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5 text-gray-700" />
        </button>
        <h2 className="text-xl text-[#212121]">
          {selectedRole === 'merchant' ? t('business_signup') :
           selectedRole === 'charity' ? t('charity_signup') :
           t('create_account')}
        </h2>
      </div>

      {/* Role Selection Modal */}
      <AnimatePresence>
        {showRoleModal && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => navigate(-1)}
            />
            
            {/* Modal */}
            <motion.div
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ type: 'spring', damping: 25 }}
              className="fixed bottom-0 left-0 right-0 bg-white rounded-t-3xl z-50 max-h-[80vh] overflow-y-auto"
            >
              <div className="p-6">
                {/* Handle */}
                <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6" />
                
                <h3 className="text-xl text-center text-[#212121] mb-6">
                  {t('who_are_you')}
                </h3>

                <div className="space-y-3">
                  {/* Consumer */}
                  <button
                    onClick={() => handleRoleSelect('consumer')}
                    className="w-full p-5 rounded-xl border-2 border-gray-200 hover:border-[#2D8659] hover:bg-[#2D8659]/5 transition-all text-left group"
                  >
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-full bg-[#2D8659]/10 group-hover:bg-[#2D8659]/20 flex items-center justify-center flex-shrink-0 transition-colors">
                        <ShoppingBag className="w-6 h-6 text-[#2D8659]" />
                      </div>
                      <div className="flex-1">
                        <div className="text-base text-[#212121] mb-1">
                          {t('consumer')}
                        </div>
                        <div className="text-sm text-[#757575]">
                          {t('consumer_desc')}
                        </div>
                      </div>
                    </div>
                  </button>

                  {/* Merchant */}
                  <button
                    onClick={() => handleRoleSelect('merchant')}
                    className="w-full p-5 rounded-xl border-2 border-gray-200 hover:border-[#2D8659] hover:bg-[#2D8659]/5 transition-all text-left group"
                  >
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-full bg-[#2D8659]/10 group-hover:bg-[#2D8659]/20 flex items-center justify-center flex-shrink-0 transition-colors">
                        <Store className="w-6 h-6 text-[#2D8659]" />
                      </div>
                      <div className="flex-1">
                        <div className="text-base text-[#212121] mb-1">
                          {t('merchant')}
                        </div>
                        <div className="text-sm text-[#757575]">
                          {t('merchant_desc')}
                        </div>
                      </div>
                    </div>
                  </button>

                  {/* Charity */}
                  <button
                    onClick={() => handleRoleSelect('charity')}
                    className="w-full p-5 rounded-xl border-2 border-gray-200 hover:border-[#2D8659] hover:bg-[#2D8659]/5 transition-all text-left group"
                  >
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-full bg-[#2D8659]/10 group-hover:bg-[#2D8659]/20 flex items-center justify-center flex-shrink-0 transition-colors">
                        <Heart className="w-6 h-6 text-[#2D8659]" />
                      </div>
                      <div className="flex-1">
                        <div className="text-base text-[#212121] mb-1">
                          {t('charity')}
                        </div>
                        <div className="text-sm text-[#757575]">
                          {t('charity_desc')}
                        </div>
                      </div>
                    </div>
                  </button>
                </div>

                <Button
                  onClick={() => navigate(-1)}
                  variant="ghost"
                  className="w-full mt-4"
                >
                  {t('cancel')}
                </Button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Form */}
      {selectedRole && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="flex-1 px-8 py-8 overflow-y-auto"
        >
          <form onSubmit={handleSubmit} className="max-w-md mx-auto space-y-6 pb-20">
            {/* Consumer Form */}
            {selectedRole === 'consumer' && (
              <>
                <div className="space-y-2">
                  <label className="text-sm text-[#212121]">{t('full_name')}</label>
                  <Input
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="Ahmed Benali"
                    className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm text-[#212121]">{t('email')}</label>
                  <Input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="ahmed@example.com"
                    className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm text-[#212121]">
                    {t('phone')} {t('phone_optional')}
                  </label>
                  <Input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+213 551 23 45 67"
                    className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm text-[#212121]">{t('password')}</label>
                  <div className="relative">
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659] pr-12"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500"
                    >
                      {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                    </button>
                  </div>
                  {strength && (
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                          <div
                            className={`h-full ${strength.color} transition-all`}
                            style={{ width: strength.width }}
                          />
                        </div>
                        <span className="text-xs text-gray-600">{strength.label}</span>
                      </div>
                    </div>
                  )}
                </div>

                <div className="space-y-3 pt-2">
                  <div className="flex items-start gap-3">
                    <Checkbox
                      checked={agreedToTerms}
                      onCheckedChange={(checked) => setAgreedToTerms(checked as boolean)}
                      id="terms"
                      className="mt-0.5"
                    />
                    <label htmlFor="terms" className="text-sm text-gray-700 cursor-pointer">
                      {t('agree_terms')}
                    </label>
                  </div>

                  <div className="flex items-start gap-3">
                    <Checkbox
                      checked={sendUpdates}
                      onCheckedChange={(checked) => setSendUpdates(checked as boolean)}
                      id="updates"
                      className="mt-0.5"
                    />
                    <label htmlFor="updates" className="text-sm text-gray-700 cursor-pointer">
                      {t('send_updates')}
                    </label>
                  </div>
                </div>
              </>
            )}

            {/* Merchant Form */}
            {selectedRole === 'merchant' && (
              <>
                <div className="space-y-4 pb-4">
                  <h3 className="text-base text-[#757575]">{t('business_info')}</h3>
                  
                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('business_name')}</label>
                    <Input
                      type="text"
                      value={businessName}
                      onChange={(e) => setBusinessName(e.target.value)}
                      placeholder="Boulangerie El Khobz"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('business_type')}</label>
                    <select
                      value={businessType}
                      onChange={(e) => setBusinessType(e.target.value)}
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    >
                      <option value="bakery">{t('bakery')}</option>
                      <option value="restaurant">{t('restaurant')}</option>
                      <option value="supermarket">{t('supermarket')}</option>
                      <option value="cafe">{t('cafe')}</option>
                      <option value="hotel">{t('hotel')}</option>
                    </select>
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('business_address')}</label>
                    <Input
                      type="text"
                      value={businessAddress}
                      onChange={(e) => setBusinessAddress(e.target.value)}
                      placeholder="123 Rue Didouche Mourad, Algiers"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('phone_number')}</label>
                    <Input
                      type="tel"
                      value={businessPhone}
                      onChange={(e) => setBusinessPhone(e.target.value)}
                      placeholder="+213 21 XX XX XX"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>
                </div>

                <div className="space-y-4 border-t pt-4">
                  <h3 className="text-base text-[#757575]">{t('your_contact')}</h3>
                  
                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('your_name')}</label>
                    <Input
                      type="text"
                      value={contactName}
                      onChange={(e) => setContactName(e.target.value)}
                      placeholder="Mohamed Cherif"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('email')}</label>
                    <Input
                      type="email"
                      value={contactEmail}
                      onChange={(e) => setContactEmail(e.target.value)}
                      placeholder="mohamed@elkhobz.dz"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('password')}</label>
                    <div className="relative">
                      <Input
                        type={showPassword ? 'text' : 'password'}
                        value={contactPassword}
                        onChange={(e) => setContactPassword(e.target.value)}
                        placeholder="••••••••"
                        className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659] pr-12"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500"
                      >
                        {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                      </button>
                    </div>
                    {strength && (
                      <div className="space-y-1">
                        <div className="flex items-center gap-2">
                          <div className="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                            <div
                              className={`h-full ${strength.color} transition-all`}
                              style={{ width: strength.width }}
                            />
                          </div>
                          <span className="text-xs text-gray-600">{strength.label}</span>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex items-start gap-3 pt-2">
                  <Checkbox
                    checked={agreedToTerms}
                    onCheckedChange={(checked) => setAgreedToTerms(checked as boolean)}
                    id="authorized"
                    className="mt-0.5"
                  />
                  <label htmlFor="authorized" className="text-sm text-gray-700 cursor-pointer">
                    {t('authorized_confirm')}
                  </label>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 flex gap-3">
                  <span className="text-blue-600 text-xl">ℹ️</span>
                  <p className="text-sm text-blue-800">{t('review_time')}</p>
                </div>
              </>
            )}

            {/* Charity Form */}
            {selectedRole === 'charity' && (
              <>
                <div className="space-y-4 pb-4">
                  <h3 className="text-base text-[#757575]">{t('org_info')}</h3>
                  
                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('org_name')}</label>
                    <Input
                      type="text"
                      value={orgName}
                      onChange={(e) => setOrgName(e.target.value)}
                      placeholder="Croissant Rouge Algérien - Alger"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('registration_number')}</label>
                    <Input
                      type="text"
                      value={regNumber}
                      onChange={(e) => setRegNumber(e.target.value)}
                      placeholder="06-12-XXXX"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('address')}</label>
                    <Input
                      type="text"
                      value={orgAddress}
                      onChange={(e) => setOrgAddress(e.target.value)}
                      placeholder="15 Rue Ahmed Bey, Algiers"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>
                </div>

                <div className="space-y-4 border-t pt-4">
                  <h3 className="text-base text-[#757575]">{t('contact_person')}</h3>
                  
                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('full_name')}</label>
                    <Input
                      type="text"
                      value={contactPerson}
                      onChange={(e) => setContactPerson(e.target.value)}
                      placeholder="Fatima Boudiaf"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('position')}</label>
                    <Input
                      type="text"
                      value={position}
                      onChange={(e) => setPosition(e.target.value)}
                      placeholder="Coordinator"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('email')}</label>
                    <Input
                      type="email"
                      value={orgEmail}
                      onChange={(e) => setOrgEmail(e.target.value)}
                      placeholder="fatima@croissant-rouge.dz"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('phone')}</label>
                    <Input
                      type="tel"
                      value={orgPhone}
                      onChange={(e) => setOrgPhone(e.target.value)}
                      placeholder="+213 551 XX XX XX"
                      className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659]"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-[#212121]">{t('password')}</label>
                    <div className="relative">
                      <Input
                        type={showPassword ? 'text' : 'password'}
                        value={orgPassword}
                        onChange={(e) => setOrgPassword(e.target.value)}
                        placeholder="••••••••"
                        className="w-full px-4 py-6 bg-[#f3f3f5] border-0 rounded-xl focus:ring-2 focus:ring-[#2D8659] pr-12"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500"
                      >
                        {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                      </button>
                    </div>
                    {strength && (
                      <div className="space-y-1">
                        <div className="flex items-center gap-2">
                          <div className="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                            <div
                              className={`h-full ${strength.color} transition-all`}
                              style={{ width: strength.width }}
                            />
                          </div>
                          <span className="text-xs text-gray-600">{strength.label}</span>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex items-start gap-3 pt-2">
                  <Checkbox
                    checked={agreedToTerms}
                    onCheckedChange={(checked) => setAgreedToTerms(checked as boolean)}
                    id="org-authorized"
                    className="mt-0.5"
                  />
                  <label htmlFor="org-authorized" className="text-sm text-gray-700 cursor-pointer">
                    {t('org_authorized_confirm')}
                  </label>
                </div>

                <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 flex gap-3">
                  <span className="text-yellow-600 text-xl">📄</span>
                  <p className="text-sm text-yellow-800">{t('document_upload_note')}</p>
                </div>
              </>
            )}

            {/* Submit Button */}
            <Button
              type="submit"
              disabled={!agreedToTerms}
              className="w-full bg-[#2D8659] hover:bg-[#236d48] text-white py-6 text-base rounded-xl transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {selectedRole === 'merchant' ? t('submit_approval') :
               selectedRole === 'charity' ? t('submit_verification') :
               t('create_account')}
            </Button>

            {/* Login link */}
            <div className="text-center pt-2">
              <span className="text-gray-600 text-sm">{t('already_have_account')} </span>
              <button
                type="button"
                onClick={() => navigate('/login')}
                className="text-[#2D8659] text-sm hover:underline"
              >
                {t('login')}
              </button>
            </div>
          </form>
        </motion.div>
      )}

      {/* Algerian colors accent */}
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-[#2D8659] via-white to-[#D32F2F]" />
    </div>
  );
}
