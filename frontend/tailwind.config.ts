/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ['class'],
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: '#009B9E',
          50: '#E6F7F7',
          100: '#B3E8E8',
          200: '#80D9D9',
          300: '#4DCACA',
          400: '#26BBBE',
          500: '#009B9E',
          600: '#008080',
          700: '#006666',
          800: '#004D4D',
          900: '#003333',
          foreground: '#FFFFFF',
        },
        secondary: {
          DEFAULT: '#FF6600',
          50: '#FFF0E6',
          100: '#FFD1B3',
          200: '#FFB380',
          300: '#FF944D',
          400: '#FF7A26',
          500: '#FF6600',
          600: '#CC5200',
          700: '#993D00',
          800: '#662900',
          900: '#331400',
          foreground: '#FFFFFF',
        },
        accent: {
          DEFAULT: '#FF8C66',
          50: '#FFF3EE',
          100: '#FFD9CC',
          200: '#FFBFA8',
          300: '#FFA585',
          400: '#FF8C66',
          500: '#E67A59',
          600: '#CC684D',
          700: '#B35740',
        },
        destructive: {
          DEFAULT: '#DC2626',
          foreground: '#FFFFFF',
        },
        muted: {
          DEFAULT: '#F5F5F5',
          foreground: '#737373',
        },
        card: {
          DEFAULT: '#FFFFFF',
          foreground: '#333333',
        },
        popover: {
          DEFAULT: '#FFFFFF',
          foreground: '#333333',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      keyframes: {
        'fade-in': {
          from: { opacity: '0', transform: 'translateY(4px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in': {
          from: { opacity: '0', transform: 'translateX(-8px)' },
          to: { opacity: '1', transform: 'translateX(0)' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.2s ease-out',
        'slide-in': 'slide-in 0.2s ease-out',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}