const defaultTheme = require('tailwindcss/defaultTheme')


module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,haml,html,slim,js}',
    './config/locales/**/*.yml'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
        serif: ['Noto Serif JP', ...defaultTheme.fontFamily.serif],
      },
      colors: {
        gray: {
          "50": "#FAFAFA",
          "100": "#F4F4F5",
          "200": "#E4E4E7",
          "300": "#D4D4D8",
          "400": "#A1A1AA",
          "500": "#71717A",
          "600": "#52525B",
          "700": "#3F3F46",
          "800": "#27272A",
          "900": "#18181B",
          locale: '#E5E7EB',
        },
        red: {
          "50": "#FEF2F2",
          "100": "#FEE2E2",
          "200": "#FECACA",
          "300": "#FCA5A5",
          "400": "#F87171",
          "500": "#EF4444",
          "600": "#DC2626",
          "700": "#B91C1C",
          "800": "#991B1B",
          "900": "#7F1D1D"
        },
        yellow: {
          "50": "#FFFBEB",
          "100": "#FDF6B2",
          "200": "#FEF08A",
          "300": "#FDE047",
          "400": "#FACC15",
          "500": "#EAB308",
          "600": "#D97706",
          "700": "#A16207",
          "800": "#92400E",
          "900": "#78350F"
        },
        green: {
          "50": "#ECFDF5",
          "100": "#D1FAE5",
          "200": "#A7F3D0",
          "300": "#6EE7B7",
          "400": "#34D399",
          "500": "#10B981",
          "600": "#059669",
          "700": "#047857",
          "800": "#065F46",
          "900": "#064E3B"
        },
        blue: {
          "50": "#EFF6FF",
          "100": "#DBEAFE",
          "200": "#BFDBFE",
          "300": "#93C5FD",
          "400": "#60A5FA",
          "500": "#4682B4",
          "600": "#3B77A8",
          "700": "#1D4ED8",
          "800": "#1E40AF",
          "900": "#1E3A8A"
        },
        indigo: {
          "50": "#EEF2FF",
          "100": "#E0E7FF",
          "200": "#C7D2FE",
          "300": "#A5B4FC",
          "400": "#818CF8",
          "500": "#6366F1",
          "600": "#4F46E5",
          "700": "#4338CA",
          "800": "#3730A3",
          "900": "#312E81"
        },
        purple: {
          "50": "#FAF5FF",
          "100": "#F3E8FF",
          "200": "#E9D5FF",
          "300": "#D8B4FE",
          "400": "#C084FC",
          "500": "#8B5CF6",
          "600": "#9333EA",
          "700": "#7E22CE",
          "800": "#6B21A8",
          "900": "#581C87"
        },
        pink: {
          "50": "#FDF2F8",
          "100": "#FCE7F3",
          "200": "#FBCFE8",
          "300": "#F9A8D4",
          "400": "#F472B6",
          "500": "#EC4899",
          "600": "#DB2777",
          "700": "#BE185D",
          "800": "#9D174D",
          "900": "#831843"
        },
        "light-blue": {
          "700": "#0369A1",
        },
      },
      gridTemplateColumns: {
        "deal-card": "4.875rem 1fr",
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    //require('daisyui'),
  ],
  safelist: [
    'list-inside',
    ...[...Array(100).keys()].flatMap(i => `w-\[${i+1}\%\]`),
    {
      pattern: /deal-status-./
    },
    {
      pattern: /badge-./
    },
    {
      pattern: /blur-(sm|md|lg|xl|2xl)/
    },
  ],
  darkMode: 'selector',
}
