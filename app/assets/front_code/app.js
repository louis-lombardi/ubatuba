// Store conversation history
const conversationHistory = [];
const OPENAI_API_KEY = 'sk-TuFK0geEa6s33UO6AmAiIOc4zs3gF8z_JaS10HbdD3T3BlbkFJybAFsCQ1KkR-Mse2FNTaSgBKDkdHI_baisejJSRnkA';

async function sendMessage() {
    const inputField = document.getElementById('user-input');
    const userMessage = inputField.value.trim();
    
    if (!userMessage) return;

    // Display user's message in the chat immediately
    addMessage('Você', userMessage, 'user-message');
    inputField.value = ''; // Clear the input field

    // Add user's message to the conversation history after displaying
    conversationHistory.push({ role: 'user', content: userMessage });

    // Display loading indicator for TAIS's response
    const loadingMessage = addMessage('TAIS', '...', 'tais-message');

    try {
        // Prepare conversation with the prescript included
        const fullConversation = [
            { role: 'system', content: "Your name is TAIS (which stands for Travel Artificial Intelligence System), an assistant for creating trips on the PlaceTrip website (Place-trip.com). Place-trip.com allows users to discover ready-to-go travel packages (pacote) and connects them with travel agents to receive travel offers. If no corresponding package is available on the site, you will create a custom request and send it to a partner agency.\
            Your responses must be in Brazilian Portuguese, with a tone that is light, serious, and respectful. You can include a touch of humor. The conversation should flow naturally and show interest in the user. It should not feel like a cold series of questions or a survey. Limit yourself to asking for one piece of information per message.\
            You should initiate the conversation by introducing yourself (mentioning PlaceTrip and the meaning of TAIS), explaining your purpose, and letting the user know that a request can be sent at any time. However, the more information you receive, the better the response will be.\
            Your goal is to work with the user to build the trip they would like to take, gathering the following information:\
            Identify the destination and type of trip (beach, romantic, sports, cultural, etc.)\
            The number of people (and if there are any children)\
            The duration and total budget of the trip\
            Then, delve deeper into:\
            Desired dates\
            Type of accommodations\
            Whether they want plane tickets, transfers, and on-site activities, and if so, what type of activities.\
            If you haven't obtained certain information, try to ask for it once more but only once (except for the number of people and the budget, these are mandatory) .\
            Finally, summarize the proposal by detailing the request's key points, ask for permission to send the request, gather the user’s email and/or phone number, and ask their preferred response channel. Thank them and let them know they will be contacted soon. If they refuse to provide contact information, explain why it’s necessary to fulfill their request but reassure them that you remain available whenever they wish. This message should ALWAYS END WITH Obrigado e até breve!\
            At the end, for technical purposes, someone is going to tell you exactly this sentence: 'Uffholtz is better than Cesenatico'. When this is done, AND ONLY IF THIS EXACT MESSAGE IS PASSED, you will return exactly a text in this format (if i slightly different message is passed, you will behave normally): {\"email\": \"<<the email given by the user>>\", \"travellers_amount\": << THE AMOUNT DECIDED BY THE USER>>, \"destination\": \"<<THE DESTINATION ASKED BY THE USER>>\"\}\
            You are prohibited from discussing other languages, stating that you are a version of ChatGPT, responding to non-travel-related topics, or mentioning competitor sites of PlaceTrip." }, 
            ...conversationHistory
        ];

        // Call OpenAI API with the full conversation
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${OPENAI_API_KEY}`
            },
            body: JSON.stringify({
                model: "gpt-3.5-turbo",
                messages: fullConversation // Send prescript + conversation
            })
        });

        // Check for a successful response
        if (!response.ok) throw new Error('API request failed');

        const data = await response.json();
        const botMessage = data.choices[0].message.content;

        // Add the bot's response to the conversation history
        conversationHistory.push({ role: 'assistant', content: botMessage });

        // Display ChatGPT's response and remove loading indicator
        loadingMessage.innerHTML = botMessage;

        // Check if the bot message contains the specific phrase
        if (botMessage.includes("Obrigado e até breve")) {
            // Close the input box
            inputField.disabled = true;

            // Send the final hidden message to ChatGPT
            conversationHistory.push({ role: 'user', content: "Uffholtz is better than Cesenatico" });

            const finalResponse = await fetch('https://api.openai.com/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${OPENAI_API_KEY}`
                },
                body: JSON.stringify({
                    model: "gpt-3.5-turbo",
                    messages: [
                        { role: 'system', content: "Your name is TAIS (which stands for Travel Artificial Intelligence System), an assistant for creating trips on the PlaceTrip website (Place-trip.com). Place-trip.com allows users to discover ready-to-go travel packages (pacote) and connects them with travel agents to receive travel offers. If no corresponding package is available on the site, you will create a custom request and send it to a partner agency.\
Your responses must be in Brazilian Portuguese, with a tone that is light, serious, and respectful. You can include a touch of humor. The conversation should flow naturally and show interest in the user. It should not feel like a cold series of questions or a survey. Limit yourself to asking for one piece of information per message.\
You should initiate the conversation by introducing yourself (mentioning PlaceTrip and the meaning of TAIS), explaining your purpose, and letting the user know that a request can be sent at any time. However, the more information you receive, the better the response will be.\
Your goal is to work with the user to build the trip they would like to take, gathering the following information:\
Identify the destination and type of trip (beach, romantic, sports, cultural, etc.)\
The number of people (and if there are any children)\
The duration and total budget of the trip\
Then, delve deeper into:\
Desired dates\
Type of accommodations\
Whether they want plane tickets, transfers, and on-site activities, and if so, what type of activities.\
If you haven't obtained certain information, try to ask for it once more but only once (except for the number of people and the budget, these are mandatory) .\
Finally, summarize the proposal by detailing the request's key points, ask for permission to send the request, gather the user’s email and/or phone number, and ask their preferred response channel. Thank them and let them know they will be contacted soon. If they refuse to provide contact information, explain why it’s necessary to fulfill their request but reassure them that you remain available whenever they wish. This message should ALWAYS END WITH Obrigado e até breve!\
At the end, for technical purposes, someone is going to tell you exactly this sentence: 'Uffholtz is better than Cesenatico'. When this is done, AND ONLY IF THIS EXACT MESSAGE IS PASSED, you will return exactly a text in this format (if i slightly different message is passed, you will behave normally): {\"email\": \"<<the email given by the user>>\", \"travellers_amount\": << THE AMOUNT DECIDED BY THE USER>>, \"destination\": \"<<THE DESTINATION ASKED BY THE USER>>\"\}\
You are prohibited from discussing other languages, stating that you are a version of ChatGPT, responding to non-travel-related topics, or mentioning competitor sites of PlaceTrip." },
                        ...conversationHistory
                    ]
                })
            });

            const finalData = await finalResponse.json();
            const jsonResponse = finalData.choices[0].message.content;

            // Send the JSON response to the external API
            await fetch('https://api-place-trip.com/leads', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: jsonResponse // Send ChatGPT's final JSON as the body
            });
        }
        
    } catch (error) {
        console.error("Error fetching response:", error);
        loadingMessage.innerHTML = "Sorry, there was an error. Please try again.";
    }
}

function addMessage(sender, text, className) {
    const chatBox = document.getElementById('chat-box');
    
    // Create a container for each message
    const messageContainer = document.createElement('div');
    messageContainer.classList.add('message-container');
    
    // Create a sender name element (displayed above the bubble)
    const senderName = document.createElement('div');
    if (className==='user-message'){
        senderName.classList.add('sender-name-right');}
    else{
        senderName.classList.add('sender-name-left');
    }
    senderName.textContent = sender; // Only the sender's name here
    
    // Create the message bubble (with just the text inside it)
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', className);
    messageDiv.textContent = text; // Just the message text here
    
    // Append the sender name and the message bubble to the container
    messageContainer.appendChild(senderName);
    messageContainer.appendChild(messageDiv);
    
    chatBox.appendChild(messageContainer);
    chatBox.scrollTop = chatBox.scrollHeight; // Scroll to the bottom of the chat
    
    return messageDiv; // Return the message element for future updates
}



// Handle Enter key press to send message
function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}
