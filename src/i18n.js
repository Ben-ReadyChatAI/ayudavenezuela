export const locales = ['es', 'en'];

// pick a localized string from a { es, en } object, falling back to Spanish
export const tt = (obj, lang) => (obj && (obj[lang] ?? obj.es)) ?? '';

export const otherLocale = (lang) => (lang === 'es' ? 'en' : 'es');

// path for a locale (Spanish is the default/un-prefixed locale)
export const localePath = (lang) => (lang === 'es' ? '/' : '/en/');

export const hostOf = (url) => {
  if (!url) return '';
  try {
    return new URL(url).hostname.replace(/^www\./, '');
  } catch {
    return '';
  }
};
