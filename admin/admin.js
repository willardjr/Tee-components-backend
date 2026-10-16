const $ = (selector) => document.querySelector(selector);
let csrfToken = '';
let signedInAdmin = null;
const api = async (url, options = {}) => {
  const headers = new Headers(options.headers || {});
  if (!['GET', 'HEAD'].includes((options.method || 'GET').toUpperCase()) && csrfToken) headers.set('X-CSRF-Token', csrfToken);
  const response = await fetch(url, { ...options, headers });
  const body = response.status === 204 ? '' : await response.text();
  let data = {};
  if (body) {
    try { data = JSON.parse(body); }
    catch (_) {
      const message = body.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
      throw new Error(message || `The server returned an invalid response (${response.status}).`);
    }
  }
  if (!response.ok) throw new Error(data.message || 'Something went wrong.');
  return data;
};

function refreshIcons() { window.lucide?.createIcons(); }
function configurePasswordToggles() {
  document.querySelectorAll('[data-password-toggle]').forEach((input) => {
    if (input.closest('.password-field')) return;
    const wrapper = document.createElement('span');
    wrapper.className = 'password-field';
    input.parentNode.insertBefore(wrapper, input);
    wrapper.appendChild(input);
    const button = document.createElement('button');
    button.type = 'button'; button.className = 'password-toggle'; button.setAttribute('aria-label', 'Show password');
    button.innerHTML = '<i data-lucide="eye"></i><span class="sr-only">Show password</span>';
    button.addEventListener('click', () => {
      const show = input.type === 'password'; input.type = show ? 'text' : 'password';
      button.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
      button.innerHTML = `<i data-lucide="${show ? 'eye-off' : 'eye'}"></i><span class="sr-only">${show ? 'Hide' : 'Show'} password</span>`;
      refreshIcons();
    });
    wrapper.appendChild(button);
  });
}
function showSection(sectionId, updateHash = true) {
  // A bookmarked #users URL must never reveal the account-management screen to an ordinary admin.
  if (sectionId === 'users' && signedInAdmin?.role !== 'super_admin') sectionId = 'overview';
  const section = document.getElementById(sectionId);
  if (!section) return;
  document.querySelectorAll('.admin-section').forEach((item) => item.classList.toggle('hidden', item.id !== sectionId));
  document.querySelectorAll('.nav-link[data-section]').forEach((link) => {
    const active = link.dataset.section === sectionId;
    link.classList.toggle('active', active);
    link.setAttribute('aria-current', active ? 'page' : 'false');
  });
  if (updateHash) window.history.replaceState(null, '', `#${sectionId}`);
}
function configureSectionNavigation() {
  document.querySelectorAll('[data-section]').forEach((link) => link.addEventListener('click', (event) => {
    event.preventDefault();
    showSection(link.dataset.section);
  }));
}
function updateCounts() {}
function renderSignedInAdmin() {
  const label = $('#signed-in-as');
  if (!label || !signedInAdmin) return;
  label.textContent = `Signed in as ${signedInAdmin.name} · ${signedInAdmin.role === 'super_admin' ? 'Super admin' : 'Admin'}`;
}
async function loadProfile() {
  if (!signedInAdmin) return;
  const result = await api('/api/admin/profile.php');
  const profile = result.profile;
  const form = $('#profile-form');
  if (!form) return;
  form.elements.name.value = profile.name || '';
  form.elements.email.value = profile.email || '';
  $('#profile-role').textContent = profile.role === 'super_admin' ? 'Super administrator' : 'Administrator';
  const created = profile.created_at ? new Date(profile.created_at.replace(' ', 'T')).toLocaleString() : 'Unknown';
  $('#profile-meta').textContent = `Account created: ${created}`;
  renderSignedInAdmin();
}
let managedUsers = [];
function configureUserAccess() {
  const isSuperAdmin = signedInAdmin?.role === 'super_admin';
  $('#users-nav')?.classList.toggle('hidden', !isSuperAdmin);
  if (!isSuperAdmin) $('#users')?.classList.add('hidden');
}
async function loadUsers() {
  if (signedInAdmin?.role !== 'super_admin') return;
  managedUsers = await api('/api/admin/users.php');
  const formatDate = (value) => value ? new Date(value.replace(' ', 'T')).toLocaleString() : 'Never';
  $('#user-list').innerHTML = managedUsers.map((user) => {
    const suspended = user.suspended_until && new Date(user.suspended_until.replace(' ', 'T')) > new Date();
    const permanentlyDeactivated = !Number(user.is_active);
    const dateValue = user.suspended_until ? user.suspended_until.slice(0, 16).replace(' ', 'T') : '';
    const state = permanentlyDeactivated ? 'PERMANENTLY DEACTIVATED' : suspended ? 'SUSPENDED' : 'ACTIVE';
    const detail = permanentlyDeactivated ? 'Access disabled permanently' : suspended ? `Suspended until: ${formatDate(user.suspended_until)}` : '';
    const actions = permanentlyDeactivated
      ? `<button type="button" data-reactivate-permanent="${user.id}" class="btn-outline text-xs">↻ Reactivate account</button>`
      : `<div class="flex flex-wrap items-center gap-2"><input data-suspension-date="${user.id}" class="field text-xs" type="datetime-local" value="${dateValue}" aria-label="Reactivation date for ${escapeHtml(user.name)}"><button type="button" data-suspend-user="${user.id}" class="btn-outline text-xs">⏱ Suspend until date</button>${suspended ? `<button type="button" data-restore-user="${user.id}" class="btn-outline text-xs">↻ Reactivate now</button>` : ''}<button type="button" data-deactivate-permanent="${user.id}" class="btn-outline text-xs text-red-700 hover:border-red-300 hover:bg-red-50">⊘ Deactivate permanently</button></div>`;
    return `<article class="flex flex-col gap-3 rounded-xl border border-slate-200 p-4 sm:flex-row sm:items-center sm:justify-between"><div><p class="font-mono text-[10px] text-brand">ADMIN · ${state}</p><h3 class="mt-1 font-extrabold">${escapeHtml(user.name)}</h3><p class="mt-1 text-xs text-slate-500">${escapeHtml(user.email)}</p><p class="mt-2 text-xs text-slate-500">Created: ${escapeHtml(formatDate(user.created_at))} · Last login: ${escapeHtml(formatDate(user.last_login_at))}${detail ? ` · ${escapeHtml(detail)}` : ''}</p></div><div class="flex flex-wrap items-center gap-2">${actions}</div></article>`;
  }).join('') || '<p class="text-sm text-slate-500">No admin users found.</p>';
  document.querySelectorAll('[data-suspend-user]').forEach((button) => button.addEventListener('click', async () => {
    const user = managedUsers.find((item) => item.id === Number(button.dataset.suspendUser));
    const input = document.querySelector(`[data-suspension-date="${button.dataset.suspendUser}"]`);
    if (!user || !input?.value) { $('#user-status').textContent = 'Choose the date and time when this account should be reactivated.'; return; }
    if (!window.confirm(`Deactivate ${user.name} until ${new Date(input.value).toLocaleString()}?`)) return;
    try { await api('/api/admin/users.php', { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: user.id, suspended_until: input.value }) }); await loadUsers(); } catch (error) { $('#user-status').textContent = error.message; }
  }));
  document.querySelectorAll('[data-restore-user]').forEach((button) => button.addEventListener('click', async () => {
    const user = managedUsers.find((item) => item.id === Number(button.dataset.restoreUser));
    if (!user || !window.confirm(`Reactivate ${user.name}'s access now?`)) return;
    try { await api('/api/admin/users.php', { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: user.id, suspended_until: '' }) }); await loadUsers(); } catch (error) { $('#user-status').textContent = error.message; }
  }));
  document.querySelectorAll('[data-deactivate-permanent]').forEach((button) => button.addEventListener('click', async () => {
    const user = managedUsers.find((item) => item.id === Number(button.dataset.deactivatePermanent));
    if (!user || !window.confirm(`Permanently deactivate ${user.name}? They will lose access immediately. Their account record will be kept.`)) return;
    try { await api('/api/admin/users.php', { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: user.id, action: 'deactivate' }) }); await loadUsers(); } catch (error) { $('#user-status').textContent = error.message; }
  }));
  document.querySelectorAll('[data-reactivate-permanent]').forEach((button) => button.addEventListener('click', async () => {
    const user = managedUsers.find((item) => item.id === Number(button.dataset.reactivatePermanent));
    if (!user || !window.confirm(`Restore ${user.name}'s admin access?`)) return;
    try { await api('/api/admin/users.php', { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: user.id, action: 'reactivate' }) }); await loadUsers(); } catch (error) { $('#user-status').textContent = error.message; }
  }));
}
function configurePublicSiteLinks() {
  if (window.location.hostname !== 'localhost') return;
  document.querySelectorAll('a[href="/"]').forEach((link) => { link.href = 'http://localhost:5173/'; });
}
const homepageImageSlots = [
  ['logo_image_id', 'Company logo'], ['hero_image_id', 'Homepage hero'], ['about_image_id', 'About image'],
  ['process_image_id', 'Work process image'], ['team_image_id', 'Team image'],
];
let siteContent = {};
let mediaItems = [];
let selectedMediaTarget = 'hero_image_id';
let mediaPickerMode = 'homepage';
function targetLabel(key) { return homepageImageSlots.find(([id]) => id === key)?.[1] || 'Homepage image'; }
function imageForContent(key) { const id = String(siteContent[key] || ''); return mediaItems.find((item) => String(item.id) === id); }
function renderHomepageSlots() {
  const slots = $('#homepage-image-slots');
  if (!slots) return;
  slots.innerHTML = homepageImageSlots.map(([key, label]) => {
    const image = imageForContent(key);
    return `<button type="button" class="homepage-image-slot ${key === selectedMediaTarget && mediaPickerMode === 'homepage' ? 'selected' : ''}" data-homepage-target="${key}">${image ? `<img src="${image.url}" alt="">` : '<div class="homepage-image-placeholder">No photo selected</div>'}<span>${label}</span></button>`;
  }).join('');
  document.querySelectorAll('[data-homepage-target]').forEach((button) => button.addEventListener('click', () => selectHomepageTarget(button.dataset.homepageTarget)));
  $('#media-upload-target').value = selectedMediaTarget;
  $('#media-selected-target').textContent = mediaPickerMode === 'service' ? 'Choosing a service photo' : `Selected: ${targetLabel(selectedMediaTarget)}`;
}
function selectHomepageTarget(key) { selectedMediaTarget = key; mediaPickerMode = 'homepage'; renderHomepageSlots(); renderMediaLibrary(); }
async function assignHomepageImage(imageId) {
  await api('/api/admin/content.php', { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ [selectedMediaTarget]: String(imageId) }) });
  siteContent[selectedMediaTarget] = String(imageId);
  renderHomepageSlots();
}
function renderServiceImagePreview(url = '') {
  const preview = $('#service-image-preview');
  if (preview) preview.innerHTML = url ? `<img src="${escapeHtml(url)}" alt="Selected service photo">` : '<span>No service photo selected</span>';
}
function configureServiceImagePicker() {
  const form = $('#service-form');
  const imageInput = form?.elements.image;
  if (!form || !imageInput) return;
  imageInput.setAttribute('capture', 'environment');
  if (!$('#service-image-preview')) {
    const picker = document.createElement('div');
    picker.className = 'wide service-image-picker';
    picker.innerHTML = '<div id="service-image-preview" class="service-image-preview"><span>No service photo selected</span></div><div><b>Service photo</b><p>Upload a photo above, or choose one from your photo library.</p><button id="choose-service-image" class="btn-outline" type="button">Choose from photo library</button></div>';
    imageInput.closest('label').insertAdjacentElement('afterend', picker);
  }
  $('#choose-service-image').addEventListener('click', () => { mediaPickerMode = 'service'; renderHomepageSlots(); renderMediaLibrary(); showSection('media'); $('#media-status').textContent = 'Choose a photo below. It will be attached to this service.'; });
  imageInput.addEventListener('change', () => { if (imageInput.files?.[0]) renderServiceImagePreview(URL.createObjectURL(imageInput.files[0])); });
}
function showDashboard(show) { $('#login-view').classList.toggle('hidden', show); $('#dashboard-view').classList.toggle('hidden', !show); $('#logout').classList.toggle('hidden', !show); $('#logout').classList.toggle('flex', show); $('#product-form').closest('section').classList.toggle('hidden', !show); }

async function loadContent() {
  siteContent = await api('/api/admin/content.php');
  document.querySelectorAll('[data-key]').forEach((input) => { input.value = siteContent[input.dataset.key] || ''; });
  renderHomepageSlots();
}

async function loadMedia() {
  mediaItems = await api('/api/admin/media.php');
  renderHomepageSlots();
  renderMediaLibrary();
}
function renderMediaLibrary() {
  const list = $('#media-list');
  if (!list) return;
  list.innerHTML = mediaItems.length ? mediaItems.map((item) => `<button type="button" data-image-id="${item.id}" class="media-library-item"><img src="${item.url}" alt="${escapeHtml(item.alt_text || item.original_name)}"><span>${escapeHtml(item.original_name)}</span></button>`).join('') : '<p class="text-sm text-slate-500">Your uploaded photos will appear here.</p>';
  document.querySelectorAll('[data-image-id]').forEach((button) => button.addEventListener('click', async () => {
    const item = mediaItems.find((image) => Number(image.id) === Number(button.dataset.imageId));
    if (!item) return;
    try {
      if (mediaPickerMode === 'service') {
        $('#service-form').elements.image_url.value = item.url;
        renderServiceImagePreview(item.url);
        $('#service-status').textContent = 'Service photo selected. Save the service to publish it.';
        showSection('services');
      } else {
        await assignHomepageImage(item.id);
        $('#media-status').textContent = `${targetLabel(selectedMediaTarget)} updated successfully.`;
      }
    } catch (error) { $('#media-status').textContent = error.message; }
  }));
}

async function uploadFormImage(form, altText) { const file = form.elements.image?.files[0]; if (!file) return form.elements.image_url.value; const data = new FormData(); data.append('image', file); data.append('alt_text', altText); const image = await api('/api/admin/media.php', { method: 'POST', body: data }); form.elements.image_url.value = image.url; return image.url; }
const defaultServiceImages = {
  'Preventive Maintenance': '/uploads/service-maintenance.jpg',
  'Networking Solutions': '/uploads/service-network.jpg',
  'IT Equipment Supply': '/uploads/service-equipment-supply.jpg',
  'Video Surveillance Systems': '/uploads/service-cctv.png',
  'Access Control Systems': '/uploads/service-access-control.png',
  'Time & Attendance Systems': '/uploads/service-access-control.png',
  'Database Design & Management': '/uploads/service-database.png',
  'Video Conferencing Systems': '/uploads/service-video-conferencing.png'
};
function imageMarkup(url, label) { return url ? `<img src="${escapeHtml(url)}" alt="">` : `<span>${escapeHtml(label)}</span>`; }
function managementCard(item, type, summary, imageUrl) { return `<article class="management-card"><div class="management-card-image">${imageMarkup(imageUrl, 'No image')}</div><div class="management-card-body"><p class="management-card-meta">${escapeHtml(type)}</p><h3>${escapeHtml(item.title)}</h3><p>${escapeHtml(summary)}</p><div class="management-card-actions"><button data-edit-${type.toLowerCase()}="${item.id}" class="text-brand">Edit</button><button data-delete-${type.toLowerCase()}="${item.id}" class="text-red-600">Delete</button></div></div></article>`; }
let services = [];
function resetServiceForm() { const form = $('#service-form'); form.reset(); form.elements.id.value = ''; form.elements.image_url.value = ''; form.elements.icon.value = 'Settings'; form.elements.sort_order.value = services.length + 1; form.elements.is_published.checked = true; renderServiceImagePreview(); $('#service-status').textContent = ''; }
function showServiceForm(service = null) { const form = $('#service-form'); form.classList.remove('hidden'); if (service) { form.elements.id.value = service.id; form.elements.title.value = service.title; form.elements.summary.value = service.summary; form.elements.details.value = service.details || ''; form.elements.benefits.value = service.benefits || ''; form.elements.service_includes.value = service.service_includes || ''; form.elements.image_url.value = service.image_url || ''; form.elements.icon.value = service.icon; form.elements.sort_order.value = service.sort_order; form.elements.is_published.checked = Boolean(Number(service.is_published)); renderServiceImagePreview(service.image_url || ''); } else resetServiceForm(); form.elements.title.focus(); }
async function loadServices() {
  services = await api('/api/admin/services.php');
  $('#service-list').innerHTML = services.length ? services.map((service) => managementCard(service, 'Service', `${service.is_published == 1 ? 'Published' : 'Draft'} · ${service.summary}`, service.image_url || defaultServiceImages[service.title])).join('') : '<p class="text-sm text-slate-500">No services have been added yet.</p>';
  document.querySelectorAll('[data-edit-service]').forEach((button) => button.addEventListener('click', () => showServiceForm(services.find((service) => service.id === Number(button.dataset.editService)))));
  document.querySelectorAll('[data-delete-service]').forEach((button) => button.addEventListener('click', async () => { const service = services.find((item) => item.id === Number(button.dataset.deleteService)); if (!service || !window.confirm(`Delete “${service.title}”?`)) return; try { await api(`/api/admin/services.php?id=${service.id}`, { method: 'DELETE' }); await loadServices(); } catch (error) { $('#service-status').textContent = error.message; } }));
  refreshIcons();
}
let newsPosts = [];
function localDate(value) { return value ? new Date(value).toISOString().slice(0, 16) : new Date().toISOString().slice(0, 16); }
function showNewsForm(post = null) { const form = $('#news-form'); form.classList.remove('hidden'); form.reset(); form.elements.id.value = post?.id || ''; form.elements.image_url.value = post?.image_url || ''; form.elements.title.value = post?.title || ''; form.elements.excerpt.value = post?.excerpt || ''; form.elements.content.value = post?.content || ''; form.elements.published_at.value = localDate(post?.published_at); form.elements.is_published.checked = post ? Boolean(Number(post.is_published)) : true; $('#news-status').textContent = ''; form.elements.title.focus(); }
async function loadNews() { newsPosts = await api('/api/admin/news.php'); $('#news-list').innerHTML = newsPosts.length ? newsPosts.map((post) => managementCard(post, 'News', `${post.is_published == 1 ? 'Published' : 'Draft'} · ${post.excerpt}`, post.image_url)).join('') : '<p class="text-sm text-slate-500">No company news has been published yet.</p>'; document.querySelectorAll('[data-edit-news]').forEach((button) => button.addEventListener('click', () => showNewsForm(newsPosts.find((post) => post.id === Number(button.dataset.editNews))))); document.querySelectorAll('[data-delete-news]').forEach((button) => button.addEventListener('click', async () => { const post = newsPosts.find((item) => item.id === Number(button.dataset.deleteNews)); if (!post || !window.confirm(`Delete “${post.title}”?`)) return; await api(`/api/admin/news.php?id=${post.id}`, { method: 'DELETE' }); await loadNews(); })); refreshIcons(); }
function escapeHtml(value) { const element = document.createElement('div'); element.textContent = value; return element.innerHTML; }

let products = [];
function showProductForm(product = null) { const form = $('#product-form'); form.classList.remove('hidden'); form.reset(); form.elements.id.value = product?.id || ''; form.elements.title.value = product?.title || ''; form.elements.description.value = product?.description || ''; form.elements.specifications.value = product?.specifications || ''; form.elements.image_url.value = product?.image_url || ''; form.elements.sort_order.value = product?.sort_order || products.length + 1; form.elements.is_published.checked = product ? Boolean(Number(product.is_published)) : true; $('#product-status').textContent = ''; form.elements.title.focus(); }
async function loadProducts() { products = await api('/api/admin/products.php'); $('#product-list').innerHTML = products.length ? products.map((product) => managementCard(product, 'Product', `${product.is_published == 1 ? 'Published' : 'Draft'} · ${product.description}`, product.image_url)).join('') : '<p class="text-sm text-slate-500">No products have been added yet.</p>'; document.querySelectorAll('[data-edit-product]').forEach((button) => button.addEventListener('click', () => showProductForm(products.find((product) => product.id === Number(button.dataset.editProduct))))); document.querySelectorAll('[data-delete-product]').forEach((button) => button.addEventListener('click', async () => { const product = products.find((item) => item.id === Number(button.dataset.deleteProduct)); if (!product || !window.confirm(`Delete “${product.title}”?`)) return; await api(`/api/admin/products.php?id=${product.id}`, { method: 'DELETE' }); await loadProducts(); })); }

$('#login-form').addEventListener('submit', async (event) => {
  event.preventDefault(); $('#login-status').textContent = '';
try { const result = await api('/api/admin/login.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(Object.fromEntries(new FormData(event.currentTarget))) }); csrfToken = result.csrf || ''; signedInAdmin = result.admin; showDashboard(true); configureUserAccess(); await Promise.all([loadProfile(), loadContent(), loadMedia(), loadServices(), loadNews(), loadProducts(), loadUsers()]); updateCounts(); showSection('overview'); } catch (error) { $('#login-status').textContent = error.message; }
});

$('#forgot-password').addEventListener('click', async () => {
  const email = $('#login-form').elements.email.value.trim();
  if (!email) { $('#login-status').textContent = 'Enter your email address first.'; $('#login-form').elements.email.focus(); return; }
  $('#login-status').textContent = 'Sending reset link…';
  try { const result = await api('/api/admin/password-reset-request.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email }) }); $('#login-status').textContent = result.message; } catch (error) { $('#login-status').textContent = error.message; }
});

$('#change-password-form').addEventListener('submit', async (event) => {
  event.preventDefault(); const form = event.currentTarget; const status = $('#password-status');
  if (form.elements.new_password.value !== form.elements.confirm_password.value) { status.textContent = 'The new passwords do not match.'; return; }
  try { const result = await api('/api/admin/change-password.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ current_password: form.elements.current_password.value, new_password: form.elements.new_password.value }) }); form.reset(); status.textContent = result.message; } catch (error) { status.textContent = error.message; }
});

$('#profile-form').addEventListener('submit', async (event) => {
  event.preventDefault(); const form = event.currentTarget; const status = $('#profile-status'); status.textContent = '';
  try { const result = await api('/api/admin/profile.php', { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(Object.fromEntries(new FormData(form))) }); signedInAdmin = result.admin; form.elements.current_password.value = ''; status.textContent = result.message; renderSignedInAdmin(); } catch (error) { status.textContent = error.message; }
});

$('#content-form').addEventListener('submit', async (event) => {
  event.preventDefault(); $('#content-status').textContent = '';
  const content = Object.fromEntries([...document.querySelectorAll('[data-key]')].map((input) => [input.dataset.key, input.value]));
  try { const result = await api('/api/admin/content.php', { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(content) }); $('#content-status').textContent = result.message; } catch (error) { $('#content-status').textContent = error.message; }
});

$('#upload-form').addEventListener('submit', async (event) => {
  event.preventDefault(); $('#media-status').textContent = '';
  try { const image = await api('/api/admin/media.php', { method: 'POST', body: new FormData(event.currentTarget) }); event.currentTarget.reset(); if (mediaPickerMode === 'service') { $('#service-form').elements.image_url.value = image.url; renderServiceImagePreview(image.url); $('#service-status').textContent = 'Service photo uploaded. Save the service to publish it.'; showSection('services'); } else { await assignHomepageImage(image.id); $('#media-status').textContent = `${targetLabel(selectedMediaTarget)} updated successfully.`; } await loadMedia(); } catch (error) { $('#media-status').textContent = error.message; }
});

$('#new-service').addEventListener('click', () => showServiceForm());
$('#cancel-service').addEventListener('click', () => $('#service-form').classList.add('hidden'));
$('#service-form').addEventListener('submit', async (event) => { event.preventDefault(); $('#service-status').textContent = ''; const form = event.currentTarget; const id = form.elements.id.value; try { await uploadFormImage(form, form.elements.title.value); const payload = Object.fromEntries(new FormData(form)); delete payload.image; payload.is_published = form.elements.is_published.checked; const result = await api(`/api/admin/services.php${id ? `?id=${id}` : ''}`, { method: id ? 'PUT' : 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) }); $('#service-status').textContent = result.message; await loadServices(); if (!id) resetServiceForm(); } catch (error) { $('#service-status').textContent = error.message; } });
$('#new-news').addEventListener('click', () => showNewsForm());
$('#cancel-news').addEventListener('click', () => $('#news-form').classList.add('hidden'));
$('#news-form').addEventListener('submit', async (event) => { event.preventDefault(); const form = event.currentTarget; const id = form.elements.id.value; try { await uploadFormImage(form, form.elements.title.value); const payload = Object.fromEntries(new FormData(form)); delete payload.image; payload.is_published = form.elements.is_published.checked; const result = await api(`/api/admin/news.php${id ? `?id=${id}` : ''}`, { method: id ? 'PUT' : 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) }); $('#news-status').textContent = result.message; await loadNews(); if (!id) showNewsForm(); } catch (error) { $('#news-status').textContent = error.message; } });
$('#new-product').addEventListener('click', () => showProductForm());
$('#cancel-product').addEventListener('click', () => $('#product-form').classList.add('hidden'));
$('#product-form').addEventListener('submit', async (event) => { event.preventDefault(); const form = event.currentTarget; const id = form.elements.id.value; try { await uploadFormImage(form, form.elements.title.value); const payload = Object.fromEntries(new FormData(form)); delete payload.image; payload.is_published = form.elements.is_published.checked; const result = await api(`/api/admin/products.php${id ? `?id=${id}` : ''}`, { method: id ? 'PUT' : 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) }); $('#product-status').textContent = result.message; await loadProducts(); if (!id) showProductForm(); } catch (error) { $('#product-status').textContent = error.message; } });
$('#new-user').addEventListener('click', () => { $('#user-form').reset(); $('#user-status').textContent = ''; $('#user-form').classList.remove('hidden'); $('#user-form').elements.name.focus(); });
$('#cancel-user').addEventListener('click', () => $('#user-form').classList.add('hidden'));
$('#user-form').addEventListener('submit', async (event) => { event.preventDefault(); const form = event.currentTarget; try { const result = await api('/api/admin/users.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(Object.fromEntries(new FormData(form))) }); $('#user-status').textContent = result.message; form.reset(); form.classList.add('hidden'); await loadUsers(); } catch (error) { $('#user-status').textContent = error.message; } });

$('#logout').addEventListener('click', async () => { try { await api('/api/admin/logout.php', { method: 'POST' }); } finally { signedInAdmin = null; csrfToken = ''; window.history.replaceState(null, '', window.location.pathname); showDashboard(false); } });
showDashboard(false);
(async () => { configurePublicSiteLinks(); configurePasswordToggles(); configureServiceImagePicker(); configureSectionNavigation(); try { const session = await api('/api/admin/session.php'); if (session.admin) { signedInAdmin = session.admin; csrfToken = session.csrf || ''; showDashboard(true); configureUserAccess(); await Promise.all([loadProfile(), loadContent(), loadMedia(), loadServices(), loadNews(), loadProducts(), loadUsers()]); updateCounts(); showSection(window.location.hash.slice(1) || 'overview', false); } } catch (_) {} refreshIcons(); })();
