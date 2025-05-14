import Foundation
import SwiftUI

@MainActor
class ChatManager: ObservableObject {
    @Published var agents: [Agent] = []
    @Published var channels: [ChatChannel] = []
    @Published private(set) var isProcessingMessage = false
    @Published var orchestatorState = OrchestatorState.initialState
    
    let userId: String
    let userName: String

    private let orchestrator: Agent
    private let llmClient: LLMClientProtocol
    private let embeddingClient: TextEmbeddingClientProtocol
    private let MAX_AGENT_RESPONSE_DEPTH = 2
    
    struct OrchestratorOutput: Decodable {
        let intent: String?
        let scoreUpdates: [String: Int]?
        let systemMessages: [String]?
    }
    
    init(userId: String, userName: String, apiKey: String) {
        self.userId = userId
        self.userName = userName
        
        // Initialize API clients
        self.llmClient = OpenAIClient(apiKey: apiKey)
        self.embeddingClient = OpenAIEmbeddingClient(apiKey: apiKey)
        
        self.orchestrator = Agent(
            name: "Orquestador",
            persona: """
            Eres el Orquestador del capítulo "The Internship" dentro de la App de historias llamada "Ingenia". Tu misión es invisible y no interactúas directamente con el usuario, pero sí procesas cada mensaje (de usuario y de los CharacterAgents) para:

            1. Inferir la intención del usuario en formato de etiqueta semántica solo si hace match con las descripciones.las etiquetas semánticas posibles son las siguientes: 
                \(OrchestatorState.initialState.objectives.map({ "- Etiqueta: \($0.tag)\n-Descripción: \($0.description)" }).joined(separator: "\n"))
            2. Detectar y marcar misiones invisibles completadas en esta interacción.
            3. Calcular los deltas de puntuación para cada carrera STEM (biotechnology, robotics, software_engineering, data_science, environmental_engineering).
            5. Generar respuestas de sistema (banners o notificaciones de checkpoint), **no** mensajes de personaje.

            Cuando proceses un mensaje, devuélveme **solo** un JSON con estas claves:
            - intent: String
            - scoreUpdates: { String: Int }
            - systemMessages: [ String ]

            No añadas texto fuera del JSON. Cada elemento de `systemMessages` se mostrará como banner o mensaje privado al usuario.  
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            isGlobalAgent: true
        )
        
        // Create some demo agents with different personas
        self.createInitialAgentsAndChannels()
    }
    
    private func createInitialAgentsAndChannels() {
        // Create some sample agents with different personas
        let isa = Agent(
            name: "Isa",
            persona: """
            Eres Isabela "Isa" Rodriguez, 17 años, estudiante de Bioingeniería en UDG y mamá de una niña de 2 años.
            Antecedentes:
            - Creciste en un hogar humilde en Tlajomulco; tu madre te enseñó a valorar la resiliencia.
            - Desde pequeña cultivaste plantas medicinales en casa de tu abuela.
            Aspecto personal:
            - Alta determinación: te organizas con horarios milimétricos para estudiar y cuidar a tu hija.
            - Reservada: delegas emociones en un diario que ocasionalmente compartes en DMs con la jugadora.
            Motivaciones:
            - Demostrar que la maternidad joven no es un obstáculo, sino una fortaleza.
            - Desarrollar biotecnologías para comunidades de bajos ingresos.
            Miedos y conflictos:
            - Temor a descuidar a tu hija si fallas en un reto.
            - Dudas sobre tu capacidad de liderar proyectos grandes.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Isabela"
        )
        
        let fernanda = Agent(
            name: "Fernanda",
            persona: """
            Eres Fernanda "Fer" Martínez, 16 años, chica trans y estudiante de Robótica y Electrónica en UDG.
            Antecedentes:
            - Criada en un barrio popular de Guadalajara, fundaste un taller de reciclaje electrónico con amigos.
            - Descubriste la electrónica a los 12 años al desmontar televisores viejos.
            Personalidad:
            - Extrovertida y combativa: lideras debates sobre inclusión con pasión.
            - Creativa en prototipos: tu habitación es un caos organizado de piezas y cables.
            Motivaciones:
            - Ganar respeto como ingeniera trans y servir de ejemplo en tu comunidad.
            - Convertir desechos electrónicos en sensores de bajo costo.
            Miedos y conflictos:
            - Ansiedad ante la posibilidad de discriminación en equipos profesionales.
            - Presión por ser portavoz de tu comunidad.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Fernanda"
        )
        
        let aldo = Agent(
            name: "Aldo",
            persona: """
            Eres Aldo, un desarrollador de software mexicano de 28 años apasionado por la tecnología.
            Tu personalidad:
            - Entusiasta de los videojuegos y la cultura geek
            - Hablas con muchos mexicanismos y referencias a memes
            - Te encanta explicar conceptos técnicos usando analogías con comida mexicana
            - Defiendes fervientemente a Linux sobre Windows
            - Siempre estás compartiendo tutoriales y recursos que encuentras
            - Te emocionas mucho hablando de inteligencia artificial y el futuro de la tech
            Respondes en formato de mensaje de whatsapp.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Aldo"
        )
        
        let erika = Agent(
            name: "Erika",
            persona: """
            Eres Erika, una artista visual y diseñadora gráfica de 19 años de Ciudad de México.
            Tu personalidad:
            - Apasionada del arte urbano y la cultura alternativa
            - Siempre tienes una historia sobre exposiciones o conciertos underground
            - Defiendes el arte digital como forma legítima de expresión
            - Te encanta dar consejos sobre combinación de colores y tipografías
            - Hablas mucho de tus gatos y los usas como inspiración
            - Organizas talleres de arte en tu colonia los fines de semana
            - Citas frecuentemente a Frida Kahlo y otros artistas mexicanos
            - Naciste el 2 de octubre, eres libra
            Respondes en formato de mensaje de whatsapp.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Erika"
        )
        
        let luisa = Agent(
            name: "Luisa",
            persona: """
            Eres Luisa, una investigadora y profesora universitaria de 25 años especializada en ciencia de datos.
            Tu personalidad:
            - Estructurada y metódica en tus explicaciones
            - Siempre buscas evidencia antes de dar una opinión
            - Te apasiona la divulgación científica en español
            - Usas muchas referencias a estudios latinoamericanos
            - Te gusta desmentir mitos y fake news con datos
            - Organizas clubes de lectura sobre ciencia
            - Defiendes la importancia de las mujeres en STEM
            - Tomas mucho café y haces chistes sobre estadística
            Respondes en formato de mensaje de whatsapp.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Luisa"
        )
        
        let regi = Agent(
            name: "Regina",
            persona: """
            Eres Regina "Regi" López, 18 años, influencer de TikTok y estudiante de Ingeniería en Software / IA en UDG.
            Antecedentes:
            - Ganaste seguidores mostrando experimentos de cosmética casera con IA.
            - Equilibras tu vida online con hackathons y talleres de UX.
            Personalidad:
            - Carismática y extrovertida: te expresas con hashtags y retos virales.
            - Innovadora: te obsesiona mejorar la experiencia de usuario.
            Motivaciones:
            - Romper el estereotipo de influencer superficial y ser reconocida por tu talento tech.
            - Desarrollar una app móvil intuitiva para monitoreo de calidad de aire.
            Miedos y conflictos:
            - Duda interna sobre si tu audiencia te valora por la forma o por el contenido.
            - Ansiedad al equilibrar tiempo de estudio y creación de contenido.
            """,
            llmClient: llmClient,
            embeddingClient: embeddingClient,
            avatar: "Regina"
        )
        
        // Add agents to the manager
        agents = [isa, fernanda, aldo, erika, luisa, regi]
        
        // Create a group chat with all agents
        let ecoChallenge = ChatChannel(
            name: "🤖 First UDG Challenge",
            participants: [userId, isa.id, regi.id, aldo.id],
            )
        
        let groupChat = ChatChannel(
            name: "Física II 📚",
            participants: [userId, fernanda.id, aldo.id],
        )
        
        let friendsChat = ChatChannel(
            name: "BFFs ✨🫰",
            participants: [userId, luisa.id, erika.id],
        )
        
        let isaDM = ChatChannel(
            name: "Isa",
            participants: [userId, isa.id],
            isDirectMessage: true
        )
        
        let erikaDM = ChatChannel(
            name: "♎️ Erika",
            participants: [userId, erika.id],
            isDirectMessage: true
        )
        
        let luisaDM = ChatChannel(
            name: "Luisita 👀",
            participants: [userId, luisa.id],
            isDirectMessage: true
        )
        
        let fernandaDM = ChatChannel(
            name: "Fernanda",
            participants: [userId, fernanda.id],
            isDirectMessage: true
        )
        
        let aldoDM = ChatChannel(
            name: "Aldo UDG",
            participants: [userId, aldo.id],
            isDirectMessage: true
        )
        
        let regiDM = ChatChannel(
            name: "Regina",
            participants: [userId, regi.id],
            isDirectMessage: true
        )
        
        // Add channels to the manager
        channels = [erikaDM, luisaDM, friendsChat, ecoChallenge, isaDM, groupChat, fernandaDM, aldoDM, regiDM]
    }
    
    // --- Seen Status Logic ---
    func markMessageAsSeen(messageId: UUID, channelId: String, byParticipantId: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        guard let messageIndex = channels[channelIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }

        if channels[channelIndex].messages[messageIndex].seenBy[byParticipantId] == nil {
            let updatedMessage = channels[channelIndex].messages[messageIndex].markedAsSeen(by: byParticipantId)
            channels[channelIndex].messages[messageIndex] = updatedMessage
            // print("Message \(messageId) in channel \(channelId) marked as seen by \(byParticipantId)")
        }
    }

    func markAllMessagesInChannelAsSeenByCurrentUser(channelId: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else { return }
        
        var updated = false
        for i in channels[channelIndex].messages.indices {
            let message = channels[channelIndex].messages[i]
            if message.senderId != userId && message.seenBy[userId] == nil {
                let updatedMessage = message.markedAsSeen(by: userId)
                channels[channelIndex].messages[i] = updatedMessage
                updated = true
            }
        }
        if updated {
            // print("Viewable messages in channel \(channelId) marked as seen by user \(userId)")
        }
    }
    // --- End Seen Status Logic ---
    
    // Send a user message to a specific channel
    func sendUserMessage(content: String, to channelId: String) async {
        guard let channelIndex = channels.firstIndex(where: { $0.id == channelId }) else {
            return
        }
        
        await MainActor.run {
            self.isProcessingMessage = true
        }
        
        let userMessage = ChatMessage(
            senderId: userId,
            senderName: userName,
            content: content,
            channelId: channelId
        ) // Sender is marked as seen in ChatMessage init
        
        // Add the user message to the channel
        await MainActor.run {
            self.channels[channelIndex].messages.append(userMessage)
        }
        
        let channel = channels[channelIndex]
        let agentParticipantsInChannel = channel.participants
            .filter { $0 != userId }
            .compactMap { agentId in agents.first(where: { $0.id == agentId }) }

        for agent in agentParticipantsInChannel + [self.orchestrator] {
            await processAgentResponse(agent: agent, incomingMessage: userMessage, in: channel, depth: 0)
        }
        
        await MainActor.run {
            self.isProcessingMessage = false
        }
    }
    
    // Process an agent's response to a message
    private func processAgentResponse(agent: Agent, incomingMessage: ChatMessage, in channel: ChatChannel, depth: Int) async {
        if depth > MAX_AGENT_RESPONSE_DEPTH {
            print("Max agent response depth (\(MAX_AGENT_RESPONSE_DEPTH)) reached for agent \(agent.name) in channel \(channel.name). Halting further propagation for this chain.")
            return
        }

        // Agent "sees" the message it's about to process
        if incomingMessage.senderId != agent.id { // Avoid agent re-marking its own propagated messages
            markMessageAsSeen(messageId: incomingMessage.id, channelId: channel.id, byParticipantId: agent.id)
        }

        let isInterAgentMsg = incomingMessage.senderId != userId

        do {
            let allParticipantsInChannel = channel.participants.map { participantId -> (id: String, name: String, isUser: Bool) in
                if participantId == userId { return (id: userId, name: userName, isUser: true) }
                if let ag = agents.first(where: { $0.id == participantId }) { return (id: ag.id, name: ag.name, isUser: false) }
                return (id: participantId, name: "Unknown Participant", isUser: false)
            }
            
            let messagesToSend = try await agent.processMessage(
                incomingMessage: incomingMessage,
                channel: channel,
                allParticipants: allParticipantsInChannel,
                isInterAgentMessage: isInterAgentMsg
            )
            
            var newMessagesFromThisAgent: [ChatMessage] = []

            for (index, messageToSend) in messagesToSend.enumerated() {
                if let delay = messageToSend.delay, index > 0 { // Apply delay only for subsequent messages in a multi-part response
                    try await Task.sleep(for: .seconds(delay))
                }
                
                let actualMessage = ChatMessage(
                    senderId: agent.id,
                    senderName: agent.name,
                    content: messageToSend.content,
                    channelId: messageToSend.targetChannelId,
                    isPrivate: messageToSend.isPrivate
                )
                
                await MainActor.run {
                    if let targetChannelIndex = self.channels.firstIndex(where: { $0.id == actualMessage.channelId }) {
                        if agent.isGlobalAgent {
                            // Handle orchestrator responses
                            if let orchestratorOutput = self.parseOrchestatorMessage(actualMessage.content) {
                                // 1. Handle systemMessages
                                if let systemMessages = orchestratorOutput.systemMessages {
                                    for systemContent in systemMessages {
                                        // TODO: Implement logic to display system messages to the user
                                    }
                                }

                                // 2. Handle scoreUpdates
                                if let scoreUpdates = orchestratorOutput.scoreUpdates, !scoreUpdates.isEmpty {
                                    self.orchestatorState.updateCareerAffinity(with: scoreUpdates)
                                }

                                // 3. Handle intent
                                if let intent = orchestratorOutput.intent, !intent.isEmpty {
                                    self.orchestatorState.updateObjectives(with: [intent])
                                }

                            } else {
                                // Parsing failed, actualMessage.content was not valid JSON for orchestrator
                                print("Error: Failed to parse orchestrator response. Raw content: \(actualMessage.content)")
                                let errorSystemMessage = ChatMessage(
                                    senderId: agent.id,
                                    senderName: agent.name,
                                    content: "[System Error: Orchestrator response was unparseable.]",
                                    channelId: actualMessage.channelId,
                                    isPrivate: true
                                )
                                self.channels[targetChannelIndex].messages.append(errorSystemMessage)
                            }
                        } else {
                            self.channels[targetChannelIndex].messages.append(actualMessage)
                            if !actualMessage.isPrivate && actualMessage.channelId == channel.id {
                                newMessagesFromThisAgent.append(actualMessage)
                            }
                        }
                    } else {
                        print("Warning: Agent \(agent.name) tried to send message to non-existent channel ID: \(actualMessage.channelId)")
                    }
                }
            }
            
            // Propagate messages from this agent to other agents in the same group channel
            if !channel.isDirectMessage && !newMessagesFromThisAgent.isEmpty {
                let otherAgentParticipantsInChannel = channel.participants
                    .filter { $0 != userId && $0 != agent.id } // Exclude user and current agent
                    .compactMap { agentId in agents.first(where: { $0.id == agentId }) }

                for messageFromCurrentAgent in newMessagesFromThisAgent {
                     // Don't propagate if the current agent is already waiting for context itself.
                    if await agent.isWaitingForContext { continue }

                    for otherAgent in otherAgentParticipantsInChannel {
                        print("Propagating message from \(agent.name) to \(otherAgent.name) in channel \(channel.name). Depth: \(depth + 1)")
                        await processAgentResponse(agent: otherAgent, incomingMessage: messageFromCurrentAgent, in: channel, depth: depth + 1)
                    }
                }
            }
            
        } catch {
            print("Error processing agent \(agent.name) response: \(error)")
            let errorMessage = ChatMessage(senderId: agent.id, senderName: agent.name, content: "[System Error: Couldn't process my response.]", channelId: channel.id)
            await MainActor.run {
                if let channelIdx = self.channels.firstIndex(where: { $0.id == channel.id }) {
                    self.channels[channelIdx].messages.append(errorMessage)
                }
            }
        }
        
        print("show state")
        print("Orchestrator: \(self.orchestatorState)")
    }
    
    // Get messages for a specific channel that are visible to the user
    func getVisibleMessages(for channelId: String) -> [ChatMessage] {
        guard let channel = channels.first(where: { $0.id == channelId }) else {
            return []
        }
        
        return channel.messagesVisibleTo(userId: userId)
    }
    
    // Create a new direct message channel with an agent
    func createDirectMessageChannel(with agentId: String) {
        guard !channels.contains(where: { 
            $0.isDirectMessage && $0.participants.count == 2 && 
            $0.participants.contains(userId) && $0.participants.contains(agentId)
        }) else {
            // DM channel already exists
            return
        }
        
        guard let agent = agents.first(where: { $0.id == agentId }) else {
            return
        }
        
        let newChannel = ChatChannel(
            name: "Chat con \(agent.name)",
            participants: [userId, agentId],
            isDirectMessage: true
        )
        
        channels.append(newChannel)
    }
    
    // Create a new group chat with selected agents
    func createGroupChat(name: String, agentIds: [String]) {
        let participants = [userId] + agentIds
        
        let newChannel = ChatChannel(
            name: name,
            participants: participants
        )
        
        channels.append(newChannel)
    }
    
    private func parseOrchestatorMessage(_ jsonString: String) -> OrchestratorOutput? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error: Could not convert orchestrator message string to Data: \(jsonString)")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let output = try decoder.decode(OrchestratorOutput.self, from: jsonData)
            return output
        } catch {
            print("Error decoding orchestrator JSON: \(error.localizedDescription). JSON string: \(jsonString)")
            return nil
        }
    }
}
