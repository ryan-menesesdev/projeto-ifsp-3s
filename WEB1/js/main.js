import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getFirestore, collection, query, where, getDocs, setDoc, doc, getDoc, updateDoc, increment, onSnapshot, deleteDoc, serverTimestamp, addDoc, writeBatch, orderBy } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";

const firebaseConfig = {
    apiKey: "AIzaSyBfsAqNVdA2YJGGiHYGOk_lKTgc9fO--aM",
    authDomain: "projeto-ifsp-3-semestre.firebaseapp.com",
    projectId: "projeto-ifsp-3-semestre",
    storageBucket: "projeto-ifsp-3-semestre.firebasestorage.app",
    messagingSenderId: "723939427008",
    appId: "1:723939427008:web:0ce661dc92adb7598be325"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

let cartListenerUnsubscribe = null;
let allProductsOnPage = [];
let currentContainerId = '';

function showConfirmationModal(title, message, onConfirm) {
    const modal = document.getElementById('confirmation-modal');
    const modalTitle = document.getElementById('modal-title');
    const modalMessage = document.getElementById('modal-message');
    const confirmBtn = document.getElementById('modal-confirm-btn');
    const cancelBtn = document.getElementById('modal-cancel-btn');

    if (!modal) return;

    modalTitle.textContent = title;
    modalMessage.textContent = message;

    modal.style.display = 'flex';

    const hideModal = () => {
        modal.style.display = 'none';
    };

    confirmBtn.onclick = () => {
        onConfirm(); 
        hideModal();
    };

    cancelBtn.onclick = hideModal;

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            hideModal();
        }
    });
}

async function handleContactFormSubmit(event) {
    event.preventDefault(); 
    
    const form = event.target;
    const submitButton = form.querySelector('button[type="submit"]');
    submitButton.disabled = true;
    submitButton.textContent = 'Enviando...';

    const name = document.getElementById('full-name').value;
    const email = document.getElementById('email').value;
    const message = document.getElementById('message').value;

    const messageData = {
        name: name,
        email: email,
        message: message,
        sentAt: serverTimestamp(),
        read: false
    };

    try {
        await addDoc(collection(db, 'mensagens'), messageData);

        alert("Obrigado pelo seu contato! Sua mensagem foi enviada com sucesso.");

        form.reset();

    } catch (error) {
        console.error("Erro ao enviar mensagem: ", error);
        alert("Desculpe, ocorreu um erro ao enviar sua mensagem. Tente novamente.");
    } finally {
        submitButton.disabled = false;
        submitButton.textContent = 'Enviar mensagem';
    }
}

async function addToCart(productId) {
    if (!auth.currentUser) {
        alert('Você precisa estar logado para adicionar itens ao carrinho.');
        window.location.href = 'login.html';
        return;
    }
    const userId = auth.currentUser.uid;
    const cartItemRef = doc(db, 'carrinhos', userId, 'itens', productId);
    try {
        const docSnap = await getDoc(cartItemRef);
        if (docSnap.exists()) {
            await updateDoc(cartItemRef, { quantidade: increment(1) });
        } else {
            const productRef = doc(db, 'produtos', productId);
            const productSnap = await getDoc(productRef);
            if (productSnap.exists()) {
                const productData = productSnap.data();
                await setDoc(cartItemRef, {
                    nome: productData.nome,
                    preco: productData.preco,
                    imagem: productData.imagem,
                    quantidade: 1
                });
            }
        }
        alert('Produto adicionado ao carrinho!');
    } catch (error) {
        console.error("Erro ao adicionar ao carrinho: ", error);
    }
}

async function updateCartItemQuantity(productId, newQuantity) {
    if (!auth.currentUser) return;
    const userId = auth.currentUser.uid;
    const cartItemRef = doc(db, 'carrinhos', userId, 'itens', productId);
    if (newQuantity <= 0) {
        await deleteCartItem(productId);
    } else {
        await updateDoc(cartItemRef, { quantidade: newQuantity });
    }
}

async function deleteCartItem(productId) {
    if (!auth.currentUser) return;
    const userId = auth.currentUser.uid;
    const cartItemRef = doc(db, 'carrinhos', userId, 'itens', productId);
    try {
        await deleteDoc(cartItemRef);
    } catch (error) {
        console.error("Erro ao remover item: ", error);
    }
}

async function finalizePurchase() {
    const paymentMethodEl = document.getElementById('payment-method');
    if (!paymentMethodEl || !paymentMethodEl.value) {
        alert('Por favor, selecione uma forma de pagamento.');
        return;
    }
    const paymentMethod = paymentMethodEl.value;
    if (!auth.currentUser) { alert('Sua sessão expirou. Faça login novamente.'); return; }
    const checkoutButton = document.getElementById('checkout-button');
    checkoutButton.disabled = true;
    checkoutButton.textContent = 'Processando...';
    const userId = auth.currentUser.uid;
    const cartItemsRef = collection(db, 'carrinhos', userId, 'itens');
    const cartSnapshot = await getDocs(cartItemsRef);
    if (cartSnapshot.empty) {
        alert('Seu carrinho está vazio.');
        checkoutButton.disabled = false;
        checkoutButton.textContent = 'Finalizar compra';
        return;
    }
    const items = cartSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const totalPrice = items.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
    const orderData = {
        userId: userId,
        userEmail: auth.currentUser.email,
        items: items,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        status: "Preparando",
        createdAt: serverTimestamp()
    };
    try {
        const orderRef = await addDoc(collection(db, 'pedidos'), orderData);
        const batch = writeBatch(db);
        cartSnapshot.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        alert(`Pedido finalizado com sucesso!`);
        window.location.href = `payment.html?orderId=${orderRef.id}`;
    } catch (error) {
        console.error("Erro ao finalizar o pedido: ", error);
        alert('Ocorreu um erro ao finalizar seu pedido.');
        checkoutButton.disabled = false;
        checkoutButton.textContent = 'Finalizar compra';
    }
}

function applySortAndRender() {
    const sortFilter = document.getElementById('sort-filter');
    if (!sortFilter) {
        renderProducts(allProductsOnPage, currentContainerId);
        return;
    }
    const sortType = sortFilter.value;
    let sortedProducts = [...allProductsOnPage];
    switch (sortType) {
        case 'preco-asc':
            sortedProducts.sort((a, b) => a.preco - b.preco);
            break;
        case 'preco-desc':
            sortedProducts.sort((a, b) => b.preco - a.preco);
            break;
        case 'nome-asc':
            sortedProducts.sort((a, b) => a.nome.localeCompare(b.nome));
            break;
    }
    renderProducts(sortedProducts, currentContainerId);
}

async function fetchProductsByCategory(category, containerId) {
    currentContainerId = containerId;
    try {
        const q = query(collection(db, 'produtos'), where('categoria', '==', category));
        const querySnapshot = await getDocs(q);
        allProductsOnPage = [];
        querySnapshot.forEach(doc => {
            allProductsOnPage.push({ id: doc.id, ...doc.data() });
        });
        applySortAndRender();
    } catch (error) {
        console.error(`Erro ao buscar produtos: `, error);
    }
}

function renderProducts(products, containerId) {
    const gridContainer = document.getElementById(containerId);
    if (!gridContainer) return;
    gridContainer.innerHTML = '';
    if (products.length === 0) {
        gridContainer.innerHTML = '<p class="no-products-message">Nenhum produto encontrado.</p>';
        return;
    }
    products.forEach(product => {
        const formattedPrice = product.preco.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        const imageSrc = product.imagem || '../assets/avatar_placeholder.png';
        const itemHtml = `
            <li class="item-section-container">
                <div class="item-section-img-container"><img class="item-section-img" src="${imageSrc}" alt="${product.nome}" draggable="false"></div>
                <div class="item-section-description">
                    <div class="item-section-info">
                        <a class="item-section-link" href="item-display.html?id=${product.id}&categoria=${product.categoria}">
                            <h2 class="item-section-name">${product.nome}</h2>
                        </a>
                        <p class="item-section-price">${formattedPrice}</p>
                    </div>
                    <div class="item-section-add"><button class="item-section-button" data-product-id="${product.id}">Adicionar ao carrinho</button></div>
                </div>
            </li>`;
        gridContainer.innerHTML += itemHtml;
    });
    document.querySelectorAll('.item-section-button').forEach(button => {
        button.addEventListener('click', (event) => {
            addToCart(event.target.dataset.productId);
        });
    });
}

async function renderCartItems(containerId) {
    const container = document.getElementById(containerId);
    const totalPriceEl = document.getElementById('cart-total-price');
    const paymentSection = document.querySelector('.cart-section-payment');
    if (!container || !auth.currentUser) return;
    const cartItemsRef = collection(db, 'carrinhos', auth.currentUser.uid, 'itens');
    onSnapshot(cartItemsRef, (snapshot) => {
        if (snapshot.empty) {
            container.innerHTML = "<p>Seu carrinho está vazio.</p>";
            if (totalPriceEl) totalPriceEl.textContent = "Total: R$ 0,00";
            if (paymentSection) paymentSection.style.display = 'none';
            return;
        }
        if (paymentSection) paymentSection.style.display = 'flex';
        container.innerHTML = '';
        let totalPrice = 0;
        snapshot.forEach(doc => {
            const item = doc.data();
            const productId = doc.id;
            const itemTotal = item.preco * item.quantidade;
            totalPrice += itemTotal;
            const itemDiv = document.createElement('li');
            itemDiv.className = 'cart-section-item';
            itemDiv.innerHTML = `
                <div class="cart-section-img-container">
                    <img class="cart-section-img" src="${item.imagem || '../assets/avatar_placeholder.png'}" alt="${item.nome}">
                    <h2 class="cart-section-name">${item.nome}</h2>
                </div>
                <div class="cart-section-quantity-container">
                    <button class="cart-section-button decrease-qty" data-id="${productId}" aria-label="Diminuir quantidade de ${item.nome}"><i class="fas fa-minus"></i></button>
                    <p class="cart-section-quantity" aria-label="Quantidade de ${item.nome}">${item.quantidade}</p>
                    <button class="cart-section-button increase-qty" data-id="${productId}" aria-label="Aumentar quantidade de ${item.nome}"><i class="fas fa-plus"></i></button>
                </div>
                <div class="cart-section-price-container">
                    <p class="cart-section-price">Preço: ${itemTotal.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</p>
                </div>
                <div class="cart-section-trash-container">
                    <button class="cart-section-button delete-item" data-id="${productId}" aria-label="Remover ${item.nome} do carrinho"><i class="fas fa-trash-alt"></i></button>
                </div>`;
            container.appendChild(itemDiv);
            itemDiv.querySelector('.decrease-qty').addEventListener('click', () => updateCartItemQuantity(productId, item.quantidade - 1));
            itemDiv.querySelector('.increase-qty').addEventListener('click', () => updateCartItemQuantity(productId, item.quantidade + 1));
            itemDiv.querySelector('.delete-item').addEventListener('click', () => {
                showConfirmationModal(
                    'Confirmar Remoção',
                    `Tem certeza que deseja remover "${item.nome}" do carrinho?`,
                    () => deleteCartItem(productId)
                );
            });
        });
        if (totalPriceEl) {
            totalPriceEl.textContent = `Total: ${totalPrice.toLocaleString('pt-BR', { style: 'currency', 'currency': 'BRL' })}`;
        }
    });
}

async function loadProductDetails(productId, categoryName) {
    const container = document.getElementById('product-detail-container');
    if (!container) return;
    if (!productId) {
        container.innerHTML = '<h1>Produto não especificado.</h1>';
        return;
    }
    try {
        const docRef = doc(db, 'produtos', productId);
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
            populateProductPage(container, docSnap.data(), productId, categoryName);
        } else {
            container.innerHTML = '<h1>Produto não encontrado.</h1>';
        }
    } catch (error) {
        console.error("Erro ao buscar detalhes do produto:", error);
        container.innerHTML = '<h1>Ocorreu um erro ao carregar o produto.</h1>';
    }
}

function populateProductPage(container, productData, productId, categoryName) {
    container.innerHTML = '';
    const categoryLinks = { "Bolos": "cakes.html", "Bebidas": "drinks.html", "Salgados": "snacks.html", "Sobremesas": "desserts.html" };
    const backLink = document.querySelector('.top-link');
    if (backLink) {
        backLink.href = categoryLinks[categoryName] || 'index.html';
    }
    document.title = productData.nome || "Detalhes do Produto";
    const imgContainer = document.createElement('div');
    imgContainer.className = 'item-display-section-img';
    const img = document.createElement('img');
    img.className = 'item-display-img';
    img.src = productData.imagem || '../assets/avatar_placeholder.png';
    img.alt = productData.nome;
    imgContainer.appendChild(img);
    const contentContainer = document.createElement('div');
    contentContainer.className = 'item-display-section-content';
    const textContainer = document.createElement('div');
    textContainer.className = 'item-display-section-text';
    const titleEl = document.createElement('h1');
    titleEl.className = 'item-display-title';
    titleEl.textContent = productData.nome;
    const descriptionEl = document.createElement('p');
    descriptionEl.className = 'item-display-paragraph';
    descriptionEl.textContent = productData.descricao || "Descrição não disponível.";
    const priceEl = document.createElement('p');
    priceEl.className = 'item-display-paragraph';
    priceEl.textContent = `Preço: ${productData.preco.toLocaleString('pt-BR', { style: 'currency', 'currency': 'BRL' })}`;
    textContainer.appendChild(titleEl);
    textContainer.appendChild(descriptionEl);
    textContainer.appendChild(priceEl);
    const addButton = document.createElement('button');
    addButton.className = 'item-display-button';
    addButton.textContent = 'Adicionar ao carrinho';
    addButton.addEventListener('click', () => {
        addToCart(productId);
    });
    contentContainer.appendChild(textContainer);
    contentContainer.appendChild(addButton);
    container.appendChild(imgContainer);
    container.appendChild(contentContainer);
}

async function renderMyOrders() {
    const container = document.getElementById('orders-list-container');
    if (!container) return;
    if (!auth.currentUser) {
        container.innerHTML = `<p>Você precisa estar logado para ver seus pedidos. <a href="login.html">Faça login</a>.</p>`;
        return;
    }
    const userId = auth.currentUser.uid;
    const q = query(collection(db, 'pedidos'), where("userId", "==", userId), orderBy("createdAt", "desc"));
    try {
        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            container.innerHTML = '<p>Você ainda não fez nenhum pedido.</p>';
            return;
        }
        container.innerHTML = '';
        querySnapshot.forEach(doc => {
            const pedido = doc.data();
            const pedidoId = doc.id;
            const dataPedido = pedido.createdAt.toDate().toLocaleDateString('pt-BR', {
                day: '2-digit', month: 'long', year: 'numeric'
            });
            const card = document.createElement('article');
            card.className = 'order-card';
            card.setAttribute('aria-labelledby', `order-id-${pedidoId}`);
            const itensHtml = pedido.items.map(item => `<li class="order-card-items-item">${item.nome} (x${item.quantidade})</li>`).join('');
            const statusClass = `status--${pedido.status.toLowerCase().replace(/\s/g, '-')}`;
            card.innerHTML = `
                <header class="order-card-header">
                    <h2 class="order-card-subtitle" id="order-id-${pedidoId}">Pedido: #${pedidoId.toUpperCase()}</h2>
                    <p class="order-card-status ${statusClass}">${pedido.status}</p>
                </header>
                <div class="order-card-body">
                    <div class="order-card-details">
                        <p class="order-card-text"><strong>Data:</strong> ${dataPedido}</p>
                        <p class="order-card-text"><strong>Valor Total:</strong> ${pedido.totalPrice.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</p>
                        <p class="order-card-text"><strong>Pagamento:</strong> ${pedido.paymentMethod}</p>
                    </div>
                    <div class="order-card-items">
                        <h3 class="order-card-items-subtitle">Itens do Pedido:</h3>
                        <ul class="order-card-items-list">
                            ${itensHtml}
                        </ul>
                    </div>
                </div>
            `;
            container.appendChild(card);
        });
    } catch (error) {
        console.error("Erro ao buscar pedidos:", error);
        container.innerHTML = '<p>Ocorreu um erro ao carregar seus pedidos. Tente novamente mais tarde.</p>';
    }
}

function setupSortEventListener() {
    const sortSelect = document.getElementById('sort-filter');
    if (sortSelect) {
        sortSelect.addEventListener('change', applySortAndRender);
    }
}

onAuthStateChanged(auth, (user) => {
    const authLink = document.getElementById('auth-link-dropdown');
    const cartCounter = document.querySelector('.header-cart-count');
    if (user) {
        if (authLink) {
            authLink.textContent = 'Sair';
            authLink.href = '#';
            authLink.onclick = (e) => {
                e.preventDefault();
                signOut(auth).then(() => { window.location.href = 'login.html'; }).catch((error) => console.error('Erro ao fazer logout:', error));
            };
        }
        const cartItemsRef = collection(db, 'carrinhos', user.uid, 'itens');
        cartListenerUnsubscribe = onSnapshot(cartItemsRef, (snapshot) => {
            const totalItems = snapshot.docs.reduce((sum, doc) => sum + doc.data().quantidade, 0);
            if (cartCounter) {
                cartCounter.textContent = totalItems;
                cartCounter.style.display = totalItems > 0 ? 'inline-block' : 'none';
            }
        });
        const pagePath = window.location.pathname;
        if (pagePath.includes('cart.html')) {
            renderCartItems('cart-items-list');
        } else if (pagePath.includes('orders.html')) {
            renderMyOrders();
        }
    } else {
        if (authLink) {
            authLink.textContent = 'Login';
            authLink.href = 'login.html';
            authLink.onclick = null;
        }
        if (cartListenerUnsubscribe) {
            cartListenerUnsubscribe();
            cartListenerUnsubscribe = null;
        }
        if (cartCounter) {
            cartCounter.textContent = '0';
            cartCounter.style.display = 'none';
        }
        const pagePath = window.location.pathname;
        if (pagePath.includes('cart.html')) {
            const cartContainer = document.getElementById('cart-items-list');
            const totalPriceEl = document.getElementById('cart-total-price');
            const paymentSection = document.querySelector('.cart-section-payment');
            if (cartContainer) {
                cartContainer.innerHTML = '<p>Seu carrinho está vazio. <a href="login.html" style="color: #c01f13; text-decoration: underline;">Faça login</a> para adicionar itens.</p>';
            }
            if (totalPriceEl) {
                totalPriceEl.textContent = 'Total: R$ 0,00';
            }
            if (paymentSection) {
                paymentSection.style.display = 'none';
            }
        }
        if (pagePath.includes('orders.html')) {
            const ordersContainer = document.getElementById('orders-list-container');
            if (ordersContainer) {
                ordersContainer.innerHTML = `
                    <p style="text-align: center; font-size: 18px;">
                        Você não pode ver seus pedidos ainda! Por favor, 
                        <a href="login.html" style="color: #c01f13; text-decoration: underline;">entre</a> 
                        com sua conta.
                    </p>`;
            }
        }
    }
});

const loginFormEl = document.querySelector('.login-form');
if (loginFormEl) {
    loginFormEl.addEventListener('submit', (event) => {
        event.preventDefault();
        const email = document.getElementById('input-email').value;
        const password = document.getElementById('input-password').value;
        signInWithEmailAndPassword(auth, email, password)
            .then(() => { window.location.href = 'index.html'; })
            .catch((error) => { alert('Não existe conta com essas informações! Registre-se!'); });
    });
}

const registerFormEl = document.querySelector('.register-form');
if (registerFormEl) {
    const phoneInput = document.getElementById('input-phone');
    const cpfInput = document.getElementById('input-cpf');
    const formatNumericInput = (event) => {
        const input = event.target;
        input.value = input.value.replace(/\D/g, '');
    };
    if (phoneInput) phoneInput.addEventListener('input', formatNumericInput);
    if (cpfInput) cpfInput.addEventListener('input', formatNumericInput);

    registerFormEl.addEventListener('submit', async (event) => {
        event.preventDefault();
        const name = document.getElementById('input-name').value;
        const email = document.getElementById('input-email').value;
        const phone = document.getElementById('input-phone').value;
        const cpf = document.getElementById('input-cpf').value;
        const password = document.getElementById('input-password').value;
        const confirmPassword = document.getElementById('input-confirm-password').value;

        if (password !== confirmPassword) {
            alert('As senhas não coincidem!');
            return;
        }

        if (password.length < 8) {
            alert('A senha deve ter no mínimo 8 caracteres.');
            return;
        }
        const allowedDomains = [
            'gmail.com', 
            'outlook.com', 
            'outlook.com.br',
            'hotmail.com',
            'yahoo.com', 
            'yahoo.com.br', 
            'icloud.com',
            'uol.com.br', 
            'bol.com.br', 
            'terra.com.br'
        ];
        const emailDomain = email.substring(email.lastIndexOf('@') + 1).toLowerCase();
        const isDomainAllowed = allowedDomains.some(domain => emailDomain.includes(domain));

        if (!isDomainAllowed) {
            alert('Por favor, use um e-mail de domínio público válido (ex: gmail.com, outlook.com).');
            return;
        }
        
        try {
            const userCredential = await createUserWithEmailAndPassword(auth, email, password);
            const user = userCredential.user;
            await setDoc(doc(db, "usuarios", user.uid), { nome: name, email: email, telefone: phone, cpf: cpf });
            alert('Cadastro realizado com sucesso!');
            window.location.href = 'login.html';
        } catch (error) {
            alert(`Erro ao se registrar: ${error.message}`);
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const productId = urlParams.get('id');
    const categoryName = urlParams.get('categoria');
    const orderId = urlParams.get('orderId');
    const pagePath = window.location.pathname;

    if (pagePath.includes('cakes.html') || pagePath.includes('drinks.html') || pagePath.includes('snacks.html') || pagePath.includes('desserts.html')) {
        setupSortEventListener();
    }

    if (pagePath.includes('cakes.html')) fetchProductsByCategory('Bolos', 'bolos-produtos-grid');
    else if (pagePath.includes('drinks.html')) fetchProductsByCategory('Bebidas', 'bebidas-produtos-grid');
    else if (pagePath.includes('snacks.html')) fetchProductsByCategory('Salgados', 'salgados-produtos-grid');
    else if (pagePath.includes('desserts.html')) fetchProductsByCategory('Sobremesas', 'sobremesas-produtos-grid');
    else if (pagePath.includes('item-display.html')) {
        loadProductDetails(productId, categoryName);
    }
    else if (pagePath.includes('cart.html')) {
        const checkoutButton = document.getElementById('checkout-button');
        if (checkoutButton) {
            checkoutButton.addEventListener('click', () => {
                const paymentMethodEl = document.getElementById('payment-method');
                if (!paymentMethodEl || !paymentMethodEl.value) {
                    alert('Por favor, selecione uma forma de pagamento.');
                    return;
                }
                showConfirmationModal(
                    'Finalizar Pedido',
                    'Tem certeza que deseja confirmar e finalizar seu pedido?',
                    finalizePurchase 
                );
            });
        }
    }
    else if (pagePath.includes('payment.html')) {
        displayOrderConfirmation(orderId);
    }
    else if (pagePath.includes('contact.html')) {
        const contactForm = document.querySelector('.contact-section-form');
        if (contactForm) {
            contactForm.addEventListener('submit', handleContactFormSubmit);
        }
    }
});