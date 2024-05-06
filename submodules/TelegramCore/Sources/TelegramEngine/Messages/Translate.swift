import Foundation
import Postbox
import SwiftSignalKit
import TelegramApi
import MtProtoKit

public enum TranslationError {
    case generic
    case invalidMessageId
    case textIsEmpty
    case textTooLong
    case invalidLanguage
    case limitExceeded
}

func _internal_translate(network: Network, text: String, toLang: String, entities: [MessageTextEntity] = []) -> Signal<(String, [MessageTextEntity])?, TranslationError> {
    var flags: Int32 = 0
    flags |= (1 << 1)

    return network.request(Api.functions.messages.translateText(flags: flags, peer: nil, id: nil, text: [.textWithEntities(text: text, entities: apiEntitiesFromMessageTextEntities(entities, associatedPeers: SimpleDictionary()))], toLang: toLang))
    |> mapError { error -> TranslationError in
        if error.errorDescription.hasPrefix("FLOOD_WAIT") {
            return .limitExceeded
        } else if error.errorDescription == "MSG_ID_INVALID" {
            return .invalidMessageId
        } else if error.errorDescription == "INPUT_TEXT_EMPTY" {
            return .textIsEmpty
        } else if error.errorDescription == "INPUT_TEXT_TOO_LONG" {
            return .textTooLong
        } else if error.errorDescription == "TO_LANG_INVALID" {
            return .invalidLanguage
        } else {
            return .generic
        }
    }
    |> mapToSignal { result -> Signal<(String, [MessageTextEntity])?, TranslationError> in
        switch result {
        case let .translateResult(results):
            if case let .textWithEntities(text, entities) = results.first {
                return .single((text, messageTextEntitiesFromApiEntities(entities)))
            } else {
                return .single(nil)
            }
        }
    }
}

func _internal_translate_texts(network: Network, texts: [(String, [MessageTextEntity])], toLang: String) -> Signal<[(String, [MessageTextEntity])], TranslationError> {
    var flags: Int32 = 0
    flags |= (1 << 1)
    
    var apiTexts: [Api.TextWithEntities] = []
    for text in texts {
        apiTexts.append(.textWithEntities(text: text.0, entities: apiEntitiesFromMessageTextEntities(text.1, associatedPeers: SimpleDictionary())))
    }

    return network.request(Api.functions.messages.translateText(flags: flags, peer: nil, id: nil, text: apiTexts, toLang: toLang))
    |> mapError { error -> TranslationError in
        if error.errorDescription.hasPrefix("FLOOD_WAIT") {
            return .limitExceeded
        } else if error.errorDescription == "MSG_ID_INVALID" {
            return .invalidMessageId
        } else if error.errorDescription == "INPUT_TEXT_EMPTY" {
            return .textIsEmpty
        } else if error.errorDescription == "INPUT_TEXT_TOO_LONG" {
            return .textTooLong
        } else if error.errorDescription == "TO_LANG_INVALID" {
            return .invalidLanguage
        } else {
            return .generic
        }
    }
    |> mapToSignal { result -> Signal<[(String, [MessageTextEntity])], TranslationError> in
        var texts: [(String, [MessageTextEntity])] = []
        switch result {
        case let .translateResult(results):
            for result in results {
                if case let .textWithEntities(text, entities) = result {
                    texts.append((text, messageTextEntitiesFromApiEntities(entities)))
                }
            }
        }
        return .single(texts)
    }
}


func _internal_translateMessages(account: Account, messageIds: [EngineMessage.Id], toLang: String) -> Signal<Void, TranslationError> {
    guard let peerId = messageIds.first?.peerId else {
        return .never()
    }
    return account.postbox.transaction { transaction -> (Api.InputPeer?, [Message]) in
        return (transaction.getPeer(peerId).flatMap(apiInputPeer), messageIds.compactMap({ transaction.getMessage($0)  }))
    }
    |> castError(TranslationError.self)
    |> mapToSignal { (inputPeer, messages) -> Signal<Void, TranslationError> in
        guard let inputPeer = inputPeer else {
            return .never()
        }
        
        let polls = messages.compactMap { msg in
            if let poll = msg.media.first as? TelegramMediaPoll {
                return (poll, msg.id)
            } else {
                return nil
            }
        }
        let pollSignals = polls.map { (poll, id) in
            var texts: [(String, [MessageTextEntity])] = []
            texts.append((poll.text, poll.textEntities))
            for option in poll.options {
                texts.append((option.text, option.entities))
            }
            if let solution = poll.results.solution {
                texts.append((solution.text, solution.entities))
            }
            return _internal_translate_texts(network: account.network, texts: texts, toLang: toLang)
        }
        
        
        var flags: Int32 = 0
        flags |= (1 << 0)
        
        let id: [Int32] = messageIds.map { $0.id }
        
        let msgs: Signal<Api.messages.TranslatedText?, TranslationError>
        if id.isEmpty {
            msgs = .single(nil)
        } else {
            msgs = account.network.request(Api.functions.messages.translateText(flags: flags, peer: inputPeer, id: id, text: nil, toLang: toLang))
            |> map(Optional.init)
            |> mapError { error -> TranslationError in
                if error.errorDescription.hasPrefix("FLOOD_WAIT") {
                    return .limitExceeded
                } else if error.errorDescription == "MSG_ID_INVALID" {
                    return .invalidMessageId
                } else if error.errorDescription == "INPUT_TEXT_EMPTY" {
                    return .textIsEmpty
                } else if error.errorDescription == "INPUT_TEXT_TOO_LONG" {
                    return .textTooLong
                } else if error.errorDescription == "TO_LANG_INVALID" {
                    return .invalidLanguage
                } else {
                    return .generic
                }
            }
        }
        
        return combineLatest(msgs, combineLatest(pollSignals))
        |> mapToSignal { (result, pollResults) -> Signal<Void, TranslationError> in
            return account.postbox.transaction { transaction in
                if case let .translateResult(results) = result {
                    var index = 0
                    for result in results {
                        let messageId = messageIds[index]
                        if case let .textWithEntities(text, entities) = result {
                            let updatedAttribute: TranslationMessageAttribute = TranslationMessageAttribute(text: text, entities: messageTextEntitiesFromApiEntities(entities), toLang: toLang)
                            transaction.updateMessage(messageId, update: { currentMessage in
                                let storeForwardInfo = currentMessage.forwardInfo.flatMap(StoreMessageForwardInfo.init)
                                var attributes = currentMessage.attributes.filter { !($0 is TranslationMessageAttribute) }
                                
                                attributes.append(updatedAttribute)
                                
                                return .update(StoreMessage(id: currentMessage.id, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: attributes, media: currentMessage.media))
                            })
                        }
                        index += 1
                    }
                }
                if !pollResults.isEmpty {
                    for (i, poll) in polls.enumerated() {
                        let result = pollResults[i]
                        transaction.updateMessage(poll.1, update: { currentMessage in
                            let storeForwardInfo = currentMessage.forwardInfo.flatMap(StoreMessageForwardInfo.init)
                            var attributes = currentMessage.attributes.filter { !($0 is TranslationMessageAttribute) }
                            var attrOptions: [TranslationMessageAttribute.Additional] = []
                            for (i, _) in poll.0.options.enumerated() {
                                let translated = result[i + 1]
                                attrOptions.append(.init(text: translated.0, entities: translated.1))
                            }
                            
                            let solution: TranslationMessageAttribute.Additional?
                            if result.count > 1 + poll.0.options.count {
                                solution = .init(text: result[result.count - 1].0, entities: result[result.count - 1].1)
                            } else {
                                solution = nil
                            }
                            
                            let updatedAttribute: TranslationMessageAttribute = TranslationMessageAttribute(text: result[0].0, entities: result[0].1, additional: attrOptions, pollSolution: solution, toLang: toLang)
                            attributes.append(updatedAttribute)
                            
                            return .update(StoreMessage(id: currentMessage.id, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: attributes, media: currentMessage.media))
                        })

                    }
                }
            }
            |> castError(TranslationError.self)
        }
    }
}

func _internal_togglePeerMessagesTranslationHidden(account: Account, peerId: EnginePeer.Id, hidden: Bool) -> Signal<Never, NoError> {
    return account.postbox.transaction { transaction -> Api.InputPeer? in
        transaction.updatePeerCachedData(peerIds: Set([peerId]), update: { _, cachedData -> CachedPeerData? in
            if let cachedData = cachedData as? CachedUserData {
                var updatedFlags = cachedData.flags
                if hidden {
                    updatedFlags.insert(.translationHidden)
                } else {
                    updatedFlags.remove(.translationHidden)
                }
                return cachedData.withUpdatedFlags(updatedFlags)
            } else if let cachedData = cachedData as? CachedGroupData {
                var updatedFlags = cachedData.flags
                if hidden {
                    updatedFlags.insert(.translationHidden)
                } else {
                    updatedFlags.remove(.translationHidden)
                }
                return cachedData.withUpdatedFlags(updatedFlags)
            } else if let cachedData = cachedData as? CachedChannelData {
                var updatedFlags = cachedData.flags
                if hidden {
                    updatedFlags.insert(.translationHidden)
                } else {
                    updatedFlags.remove(.translationHidden)
                }
                return cachedData.withUpdatedFlags(updatedFlags)
            } else {
                return cachedData
            }
        })
        return transaction.getPeer(peerId).flatMap(apiInputPeer)
    }
    |> mapToSignal { inputPeer -> Signal<Never, NoError> in
        guard let inputPeer = inputPeer else {
            return .never()
        }
        var flags: Int32 = 0
        if hidden {
            flags |= (1 << 0)
        }
        
        return account.network.request(Api.functions.messages.togglePeerTranslations(flags: flags, peer: inputPeer))
        |> map(Optional.init)
        |> `catch` { _ -> Signal<Api.Bool?, NoError> in
            return .single(nil)
        }
        |> ignoreValues
    }
}
