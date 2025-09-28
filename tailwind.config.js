/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md",
    "./static/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        'guild-brown': '#3D2914',
        'guild-brown-dark': '#2A1C0E',
        'guild-beige': '#D4C4A8',
        'guild-beige-light': '#E8DCC6',
        'guild-beige-dark': '#C0B094',
        'guild-gold': '#B8860B',
        'guild-blue': '#2C3E50',
        'guild-blue-dark': '#1A252F',
        'guild-blue-light': '#34495E',
      }
    },
  },
  plugins: [],
}