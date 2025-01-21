const sessionHash = crypto.randomUUID();
const agreementMessage= "Muito obrigado! Agora, temos a sua permissão para enviar suas informaçoes aos nossos parceiros?"
const thanksMessage = "Ótimo! Até logo e estarei por aqui caso precisar de mim novamente"
const verificationMessage = "Tem certeza? Sem a sua permissão, os parceiros não vão poder te ajudar com a sua viagem. Podemos enviar suas informaçoes para os nossos parceiros?"
const tooBadMessage = "Sem problemas, estarei por aqui caso precisar de mim novamente"

async function sendMessage() {
    const inputField = document.getElementById('user-input');
    const userMessage = inputField.value.trim();
    const sendButton = document.querySelector('.send-btn');
    inputField.disabled = true;
    sendButton.style.visibility='hidden';
    if (!userMessage) return;

    addMessage('Você', userMessage, 'user-message');
    inputField.value = '';
    const loadingMessage = addMessage('TAIS | Travel Artificial Intelligence System ', '...', 'tais-message');
    try {
        const response = await fetch('https://api.place-trip.com/ia_message', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                chat_id: sessionHash,
                content: userMessage
            })
        });
        if (!response.ok) throw new Error('API request failed');

        const data = await response.json();
        let botMessage = data.content;
        let chatFinalized = false;
        if (botMessage === "ENDING_CHAT"){
            botMessage = agreementMessage;
            chatFinalized = true;
            showChoiceButtons(handleChoice)
        }
        loadingMessage.innerHTML = "";
        let i = 0;
        let isTag = false; // To handle HTML tags properly
        let isATag = false
        let currentTag = ""; // Stores the ongoing tag being built
        const chatBox = document.getElementById('chat-box');
        const speed = 10; // Typing speed in milliseconds
        const interval = setInterval(() => {
        if (i < botMessage.length) {
            const char = botMessage[i]
            if (char === '\n') {
                loadingMessage.innerHTML += '<br>';
            } else if (char === "<") {
                if  (isATag) {
                    currentTag += char;
                } else {
                    isTag = true;
                    currentTag = char;
                    if (botMessage[i+1] === "a"){
                        isATag = true;
                    }
                }
            } else if (char === ">" && isTag) {
                if (!isATag || botMessage[i-1] === "a"){
                    isTag = false;
                    currentTag += char;
                    isATag = false;
                    loadingMessage.innerHTML += currentTag;
                }else if  (isATag) {
                    currentTag += char;
                }
            } else if (isTag) {
                currentTag += char;
            }else {
            loadingMessage.innerHTML += char; // Add one letter at a time
            }
            i++;
            chatBox.scrollTop = chatBox.scrollHeight; // Keep scrolling as it types
        } else {
            clearInterval(interval); // Stop when typing is done
            if (!chatFinalized) {
                inputField.disabled = false;
                sendButton.style.visibility=null;
            }
        }
    }, speed);
    } catch (error) {
        console.error("Error fetching response:", error);
        loadingMessage.innerHTML = "Puts...parece que teve uma falha na nossa comunicaçao...poderia repetir por favor?";
        if (!chatFinalized) {
            inputField.disabled = false;
            sendButton.style.visibility=null;
        }
    }
}


function addMessage(sender, text, className) {
    const chatBox = document.getElementById('chat-box');
        const messageContainer = document.createElement('div');
    messageContainer.classList.add('message-container');
        const senderName = document.createElement('div');
    if (className==='user-message'){
        senderName.classList.add('sender-name-right');}
    else{
        senderName.classList.add('sender-name-left');
    }
    senderName.textContent = sender; // Only the sender's name here
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', className);
    messageDiv.textContent = text; // Just the message text here
        messageContainer.appendChild(senderName);
    messageContainer.appendChild(messageDiv);
    chatBox.appendChild(messageContainer);
    chatBox.scrollTop = chatBox.scrollHeight; // Scroll to the bottom of the chat
    return messageDiv; // Return the message element for future updates
}

function showChoiceButtons(callBackMethod) {
    const chatBox = document.getElementById('chat-box');
    const buttonContainer = document.createElement('div');
    buttonContainer.className = 'message-container';
    const yesButton = document.createElement('button');
    yesButton.textContent = 'Sim';
    yesButton.className = 'choice-btn';
    yesButton.addEventListener('click', () => callBackMethod('Sim', buttonContainer));
    const noButton = document.createElement('button');
    noButton.textContent = 'Não';
    noButton.className = 'choice-btn';
    noButton.addEventListener('click', () => callBackMethod('Não', buttonContainer));
    buttonContainer.appendChild(yesButton);
    buttonContainer.appendChild(noButton);
    chatBox.appendChild(buttonContainer);
    chatBox.scrollTop = chatBox.scrollHeight; // Scroll to the bottom
}

function handleChoice(choice, buttonContainer) {
    buttonContainer.remove();
    addMessage('Você', choice, 'user-message');
    if (choice === 'Sim') {
        addMessage('TAIS | Travel Artificial Intelligence System', thanksMessage, 'tais-message');
        sendAcknowledge("yes");
    } else if (choice === 'Não') {
        addMessage('TAIS | Travel Artificial Intelligence System', verificationMessage, 'tais-message');
        showChoiceButtons(handleChoice2);
    }
}


function handleChoice2(choice, buttonContainer) {
    buttonContainer.remove();
    addMessage('Você', choice, 'user-message');
    if (choice === 'Sim') {
        addMessage('TAIS | Travel Artificial Intelligence System', thanksMessage, 'tais-message');
        sendAcknowledge("yes");
    } else if (choice === 'Não') {
        addMessage('TAIS | Travel Artificial Intelligence System', tooBadMessage, 'tais-message');
        sendAcknowledge("no");
    }
}


// Send acknowledge to PlaceTrip
async function sendAcknowledge(userResponse){
    try {
       const response = await fetch('https://api.place-trip.com/ia_message', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                chat_id: sessionHash,
                user_response: userResponse
            })
        });
    if (!response.ok) throw new Error('API request failed');
    } catch (error) {
        console.error("Error fetching response:", error);
    }
}


// Handle Enter key press to send message
function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}
