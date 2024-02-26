// Ambil elemen tombol untuk membuka dan menutup floating page
const openFloatingPageBtn = document.getElementById('openFloatingPageBtn');
const closeFloatingPageBtn = document.getElementById('closeFloatingPageBtn');
const floatingPage = document.getElementById('floatingPage');

// Tambahkan event listener untuk membuka floating page
openFloatingPageBtn.addEventListener('click', () => {
  floatingPage.style.display = 'block';
});

// Tambahkan event listener untuk menutup floating page
closeFloatingPageBtn.addEventListener('click', () => {
  floatingPage.style.display = 'none';
});
