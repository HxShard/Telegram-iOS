public extension Api.auth {
    enum LoginToken: TypeConstructorDescription {
        case loginToken(expires: Int32, token: Buffer)
        case loginTokenMigrateTo(dcId: Int32, token: Buffer)
        case loginTokenSuccess(authorization: Api.auth.Authorization)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .loginToken(let expires, let token):
                    if boxed {
                        buffer.appendInt32(1654593920)
                    }
                    serializeInt32(expires, buffer: buffer, boxed: false)
                    serializeBytes(token, buffer: buffer, boxed: false)
                    break
                case .loginTokenMigrateTo(let dcId, let token):
                    if boxed {
                        buffer.appendInt32(110008598)
                    }
                    serializeInt32(dcId, buffer: buffer, boxed: false)
                    serializeBytes(token, buffer: buffer, boxed: false)
                    break
                case .loginTokenSuccess(let authorization):
                    if boxed {
                        buffer.appendInt32(957176926)
                    }
                    authorization.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .loginToken(let expires, let token):
                return ("loginToken", [("expires", String(describing: expires)), ("token", String(describing: token))])
                case .loginTokenMigrateTo(let dcId, let token):
                return ("loginTokenMigrateTo", [("dcId", String(describing: dcId)), ("token", String(describing: token))])
                case .loginTokenSuccess(let authorization):
                return ("loginTokenSuccess", [("authorization", String(describing: authorization))])
    }
    }
    
        public static func parse_loginToken(_ reader: BufferReader) -> LoginToken? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Buffer?
            _2 = parseBytes(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.auth.LoginToken.loginToken(expires: _1!, token: _2!)
            }
            else {
                return nil
            }
        }
        public static func parse_loginTokenMigrateTo(_ reader: BufferReader) -> LoginToken? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Buffer?
            _2 = parseBytes(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.auth.LoginToken.loginTokenMigrateTo(dcId: _1!, token: _2!)
            }
            else {
                return nil
            }
        }
        public static func parse_loginTokenSuccess(_ reader: BufferReader) -> LoginToken? {
            var _1: Api.auth.Authorization?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.auth.Authorization
            }
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.LoginToken.loginTokenSuccess(authorization: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.auth {
    enum PasswordRecovery: TypeConstructorDescription {
        case passwordRecovery(emailPattern: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .passwordRecovery(let emailPattern):
                    if boxed {
                        buffer.appendInt32(326715557)
                    }
                    serializeString(emailPattern, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .passwordRecovery(let emailPattern):
                return ("passwordRecovery", [("emailPattern", String(describing: emailPattern))])
    }
    }
    
        public static func parse_passwordRecovery(_ reader: BufferReader) -> PasswordRecovery? {
            var _1: String?
            _1 = parseString(reader)
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.PasswordRecovery.passwordRecovery(emailPattern: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.auth {
    enum SentCode: TypeConstructorDescription {
        case sentCode(flags: Int32, type: Api.auth.SentCodeType, phoneCodeHash: String, nextType: Api.auth.CodeType?, timeout: Int32?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .sentCode(let flags, let type, let phoneCodeHash, let nextType, let timeout):
                    if boxed {
                        buffer.appendInt32(1577067778)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    type.serialize(buffer, true)
                    serializeString(phoneCodeHash, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 1) != 0 {nextType!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 2) != 0 {serializeInt32(timeout!, buffer: buffer, boxed: false)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .sentCode(let flags, let type, let phoneCodeHash, let nextType, let timeout):
                return ("sentCode", [("flags", String(describing: flags)), ("type", String(describing: type)), ("phoneCodeHash", String(describing: phoneCodeHash)), ("nextType", String(describing: nextType)), ("timeout", String(describing: timeout))])
    }
    }
    
        public static func parse_sentCode(_ reader: BufferReader) -> SentCode? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.auth.SentCodeType?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.auth.SentCodeType
            }
            var _3: String?
            _3 = parseString(reader)
            var _4: Api.auth.CodeType?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.auth.CodeType
            } }
            var _5: Int32?
            if Int(_1!) & Int(1 << 2) != 0 {_5 = reader.readInt32() }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 1) == 0) || _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 2) == 0) || _5 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 {
                return Api.auth.SentCode.sentCode(flags: _1!, type: _2!, phoneCodeHash: _3!, nextType: _4, timeout: _5)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.auth {
    enum SentCodeType: TypeConstructorDescription {
        case sentCodeTypeApp(length: Int32)
        case sentCodeTypeCall(length: Int32)
        case sentCodeTypeFlashCall(pattern: String)
        case sentCodeTypeMissedCall(prefix: String, length: Int32)
        case sentCodeTypeSms(length: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .sentCodeTypeApp(let length):
                    if boxed {
                        buffer.appendInt32(1035688326)
                    }
                    serializeInt32(length, buffer: buffer, boxed: false)
                    break
                case .sentCodeTypeCall(let length):
                    if boxed {
                        buffer.appendInt32(1398007207)
                    }
                    serializeInt32(length, buffer: buffer, boxed: false)
                    break
                case .sentCodeTypeFlashCall(let pattern):
                    if boxed {
                        buffer.appendInt32(-1425815847)
                    }
                    serializeString(pattern, buffer: buffer, boxed: false)
                    break
                case .sentCodeTypeMissedCall(let prefix, let length):
                    if boxed {
                        buffer.appendInt32(-2113903484)
                    }
                    serializeString(prefix, buffer: buffer, boxed: false)
                    serializeInt32(length, buffer: buffer, boxed: false)
                    break
                case .sentCodeTypeSms(let length):
                    if boxed {
                        buffer.appendInt32(-1073693790)
                    }
                    serializeInt32(length, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .sentCodeTypeApp(let length):
                return ("sentCodeTypeApp", [("length", String(describing: length))])
                case .sentCodeTypeCall(let length):
                return ("sentCodeTypeCall", [("length", String(describing: length))])
                case .sentCodeTypeFlashCall(let pattern):
                return ("sentCodeTypeFlashCall", [("pattern", String(describing: pattern))])
                case .sentCodeTypeMissedCall(let prefix, let length):
                return ("sentCodeTypeMissedCall", [("prefix", String(describing: prefix)), ("length", String(describing: length))])
                case .sentCodeTypeSms(let length):
                return ("sentCodeTypeSms", [("length", String(describing: length))])
    }
    }
    
        public static func parse_sentCodeTypeApp(_ reader: BufferReader) -> SentCodeType? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.SentCodeType.sentCodeTypeApp(length: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_sentCodeTypeCall(_ reader: BufferReader) -> SentCodeType? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.SentCodeType.sentCodeTypeCall(length: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_sentCodeTypeFlashCall(_ reader: BufferReader) -> SentCodeType? {
            var _1: String?
            _1 = parseString(reader)
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.SentCodeType.sentCodeTypeFlashCall(pattern: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_sentCodeTypeMissedCall(_ reader: BufferReader) -> SentCodeType? {
            var _1: String?
            _1 = parseString(reader)
            var _2: Int32?
            _2 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.auth.SentCodeType.sentCodeTypeMissedCall(prefix: _1!, length: _2!)
            }
            else {
                return nil
            }
        }
        public static func parse_sentCodeTypeSms(_ reader: BufferReader) -> SentCodeType? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.auth.SentCodeType.sentCodeTypeSms(length: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.channels {
    enum AdminLogResults: TypeConstructorDescription {
        case adminLogResults(events: [Api.ChannelAdminLogEvent], chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .adminLogResults(let events, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-309659827)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(events.count))
                    for item in events {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .adminLogResults(let events, let chats, let users):
                return ("adminLogResults", [("events", String(describing: events)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_adminLogResults(_ reader: BufferReader) -> AdminLogResults? {
            var _1: [Api.ChannelAdminLogEvent]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.ChannelAdminLogEvent.self)
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.channels.AdminLogResults.adminLogResults(events: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.channels {
    enum ChannelParticipant: TypeConstructorDescription {
        case channelParticipant(participant: Api.ChannelParticipant, chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .channelParticipant(let participant, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-541588713)
                    }
                    participant.serialize(buffer, true)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .channelParticipant(let participant, let chats, let users):
                return ("channelParticipant", [("participant", String(describing: participant)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_channelParticipant(_ reader: BufferReader) -> ChannelParticipant? {
            var _1: Api.ChannelParticipant?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.ChannelParticipant
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.channels.ChannelParticipant.channelParticipant(participant: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.channels {
    enum ChannelParticipants: TypeConstructorDescription {
        case channelParticipants(count: Int32, participants: [Api.ChannelParticipant], chats: [Api.Chat], users: [Api.User])
        case channelParticipantsNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .channelParticipants(let count, let participants, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-1699676497)
                    }
                    serializeInt32(count, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(participants.count))
                    for item in participants {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .channelParticipantsNotModified:
                    if boxed {
                        buffer.appendInt32(-266911767)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .channelParticipants(let count, let participants, let chats, let users):
                return ("channelParticipants", [("count", String(describing: count)), ("participants", String(describing: participants)), ("chats", String(describing: chats)), ("users", String(describing: users))])
                case .channelParticipantsNotModified:
                return ("channelParticipantsNotModified", [])
    }
    }
    
        public static func parse_channelParticipants(_ reader: BufferReader) -> ChannelParticipants? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: [Api.ChannelParticipant]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.ChannelParticipant.self)
            }
            var _3: [Api.Chat]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _4: [Api.User]?
            if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.channels.ChannelParticipants.channelParticipants(count: _1!, participants: _2!, chats: _3!, users: _4!)
            }
            else {
                return nil
            }
        }
        public static func parse_channelParticipantsNotModified(_ reader: BufferReader) -> ChannelParticipants? {
            return Api.channels.ChannelParticipants.channelParticipantsNotModified
        }
    
    }
}
public extension Api.channels {
    enum SendAsPeers: TypeConstructorDescription {
        case sendAsPeers(peers: [Api.Peer], chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .sendAsPeers(let peers, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-2091463255)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(peers.count))
                    for item in peers {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .sendAsPeers(let peers, let chats, let users):
                return ("sendAsPeers", [("peers", String(describing: peers)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_sendAsPeers(_ reader: BufferReader) -> SendAsPeers? {
            var _1: [Api.Peer]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Peer.self)
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.channels.SendAsPeers.sendAsPeers(peers: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.contacts {
    enum Blocked: TypeConstructorDescription {
        case blocked(blocked: [Api.PeerBlocked], chats: [Api.Chat], users: [Api.User])
        case blockedSlice(count: Int32, blocked: [Api.PeerBlocked], chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .blocked(let blocked, let chats, let users):
                    if boxed {
                        buffer.appendInt32(182326673)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(blocked.count))
                    for item in blocked {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .blockedSlice(let count, let blocked, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-513392236)
                    }
                    serializeInt32(count, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(blocked.count))
                    for item in blocked {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .blocked(let blocked, let chats, let users):
                return ("blocked", [("blocked", String(describing: blocked)), ("chats", String(describing: chats)), ("users", String(describing: users))])
                case .blockedSlice(let count, let blocked, let chats, let users):
                return ("blockedSlice", [("count", String(describing: count)), ("blocked", String(describing: blocked)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_blocked(_ reader: BufferReader) -> Blocked? {
            var _1: [Api.PeerBlocked]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PeerBlocked.self)
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.contacts.Blocked.blocked(blocked: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_blockedSlice(_ reader: BufferReader) -> Blocked? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: [Api.PeerBlocked]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PeerBlocked.self)
            }
            var _3: [Api.Chat]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _4: [Api.User]?
            if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.contacts.Blocked.blockedSlice(count: _1!, blocked: _2!, chats: _3!, users: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.contacts {
    enum Contacts: TypeConstructorDescription {
        case contacts(contacts: [Api.Contact], savedCount: Int32, users: [Api.User])
        case contactsNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .contacts(let contacts, let savedCount, let users):
                    if boxed {
                        buffer.appendInt32(-353862078)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(contacts.count))
                    for item in contacts {
                        item.serialize(buffer, true)
                    }
                    serializeInt32(savedCount, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .contactsNotModified:
                    if boxed {
                        buffer.appendInt32(-1219778094)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .contacts(let contacts, let savedCount, let users):
                return ("contacts", [("contacts", String(describing: contacts)), ("savedCount", String(describing: savedCount)), ("users", String(describing: users))])
                case .contactsNotModified:
                return ("contactsNotModified", [])
    }
    }
    
        public static func parse_contacts(_ reader: BufferReader) -> Contacts? {
            var _1: [Api.Contact]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Contact.self)
            }
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.contacts.Contacts.contacts(contacts: _1!, savedCount: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_contactsNotModified(_ reader: BufferReader) -> Contacts? {
            return Api.contacts.Contacts.contactsNotModified
        }
    
    }
}
public extension Api.contacts {
    enum Found: TypeConstructorDescription {
        case found(myResults: [Api.Peer], results: [Api.Peer], chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .found(let myResults, let results, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-1290580579)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(myResults.count))
                    for item in myResults {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(results.count))
                    for item in results {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .found(let myResults, let results, let chats, let users):
                return ("found", [("myResults", String(describing: myResults)), ("results", String(describing: results)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_found(_ reader: BufferReader) -> Found? {
            var _1: [Api.Peer]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Peer.self)
            }
            var _2: [Api.Peer]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Peer.self)
            }
            var _3: [Api.Chat]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _4: [Api.User]?
            if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.contacts.Found.found(myResults: _1!, results: _2!, chats: _3!, users: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.contacts {
    enum ImportedContacts: TypeConstructorDescription {
        case importedContacts(imported: [Api.ImportedContact], popularInvites: [Api.PopularContact], retryContacts: [Int64], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .importedContacts(let imported, let popularInvites, let retryContacts, let users):
                    if boxed {
                        buffer.appendInt32(2010127419)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(imported.count))
                    for item in imported {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(popularInvites.count))
                    for item in popularInvites {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(retryContacts.count))
                    for item in retryContacts {
                        serializeInt64(item, buffer: buffer, boxed: false)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .importedContacts(let imported, let popularInvites, let retryContacts, let users):
                return ("importedContacts", [("imported", String(describing: imported)), ("popularInvites", String(describing: popularInvites)), ("retryContacts", String(describing: retryContacts)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_importedContacts(_ reader: BufferReader) -> ImportedContacts? {
            var _1: [Api.ImportedContact]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.ImportedContact.self)
            }
            var _2: [Api.PopularContact]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PopularContact.self)
            }
            var _3: [Int64]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 570911930, elementType: Int64.self)
            }
            var _4: [Api.User]?
            if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.contacts.ImportedContacts.importedContacts(imported: _1!, popularInvites: _2!, retryContacts: _3!, users: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.contacts {
    enum ResolvedPeer: TypeConstructorDescription {
        case resolvedPeer(peer: Api.Peer, chats: [Api.Chat], users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .resolvedPeer(let peer, let chats, let users):
                    if boxed {
                        buffer.appendInt32(2131196633)
                    }
                    peer.serialize(buffer, true)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .resolvedPeer(let peer, let chats, let users):
                return ("resolvedPeer", [("peer", String(describing: peer)), ("chats", String(describing: chats)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_resolvedPeer(_ reader: BufferReader) -> ResolvedPeer? {
            var _1: Api.Peer?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.Peer
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.contacts.ResolvedPeer.resolvedPeer(peer: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api.contacts {
    enum TopPeers: TypeConstructorDescription {
        case topPeers(categories: [Api.TopPeerCategoryPeers], chats: [Api.Chat], users: [Api.User])
        case topPeersDisabled
        case topPeersNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .topPeers(let categories, let chats, let users):
                    if boxed {
                        buffer.appendInt32(1891070632)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(categories.count))
                    for item in categories {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .topPeersDisabled:
                    if boxed {
                        buffer.appendInt32(-1255369827)
                    }
                    
                    break
                case .topPeersNotModified:
                    if boxed {
                        buffer.appendInt32(-567906571)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .topPeers(let categories, let chats, let users):
                return ("topPeers", [("categories", String(describing: categories)), ("chats", String(describing: chats)), ("users", String(describing: users))])
                case .topPeersDisabled:
                return ("topPeersDisabled", [])
                case .topPeersNotModified:
                return ("topPeersNotModified", [])
    }
    }
    
        public static func parse_topPeers(_ reader: BufferReader) -> TopPeers? {
            var _1: [Api.TopPeerCategoryPeers]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.TopPeerCategoryPeers.self)
            }
            var _2: [Api.Chat]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.contacts.TopPeers.topPeers(categories: _1!, chats: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_topPeersDisabled(_ reader: BufferReader) -> TopPeers? {
            return Api.contacts.TopPeers.topPeersDisabled
        }
        public static func parse_topPeersNotModified(_ reader: BufferReader) -> TopPeers? {
            return Api.contacts.TopPeers.topPeersNotModified
        }
    
    }
}
public extension Api.feed {
    enum FeedMessages: TypeConstructorDescription {
        case feedMessages(flags: Int32, maxPosition: Api.FeedPosition?, minPosition: Api.FeedPosition?, readMaxPosition: Api.FeedPosition?, messages: [Api.Message], chats: [Api.Chat], users: [Api.User])
        case feedMessagesNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .feedMessages(let flags, let maxPosition, let minPosition, let readMaxPosition, let messages, let chats, let users):
                    if boxed {
                        buffer.appendInt32(-587770695)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {maxPosition!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 1) != 0 {minPosition!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 2) != 0 {readMaxPosition!.serialize(buffer, true)}
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(messages.count))
                    for item in messages {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(chats.count))
                    for item in chats {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .feedMessagesNotModified:
                    if boxed {
                        buffer.appendInt32(-619039485)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .feedMessages(let flags, let maxPosition, let minPosition, let readMaxPosition, let messages, let chats, let users):
                return ("feedMessages", [("flags", String(describing: flags)), ("maxPosition", String(describing: maxPosition)), ("minPosition", String(describing: minPosition)), ("readMaxPosition", String(describing: readMaxPosition)), ("messages", String(describing: messages)), ("chats", String(describing: chats)), ("users", String(describing: users))])
                case .feedMessagesNotModified:
                return ("feedMessagesNotModified", [])
    }
    }
    
        public static func parse_feedMessages(_ reader: BufferReader) -> FeedMessages? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.FeedPosition?
            if Int(_1!) & Int(1 << 0) != 0 {if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.FeedPosition
            } }
            var _3: Api.FeedPosition?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.FeedPosition
            } }
            var _4: Api.FeedPosition?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.FeedPosition
            } }
            var _5: [Api.Message]?
            if let _ = reader.readInt32() {
                _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Message.self)
            }
            var _6: [Api.Chat]?
            if let _ = reader.readInt32() {
                _6 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Chat.self)
            }
            var _7: [Api.User]?
            if let _ = reader.readInt32() {
                _7 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = (Int(_1!) & Int(1 << 0) == 0) || _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 1) == 0) || _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 2) == 0) || _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 {
                return Api.feed.FeedMessages.feedMessages(flags: _1!, maxPosition: _2, minPosition: _3, readMaxPosition: _4, messages: _5!, chats: _6!, users: _7!)
            }
            else {
                return nil
            }
        }
        public static func parse_feedMessagesNotModified(_ reader: BufferReader) -> FeedMessages? {
            return Api.feed.FeedMessages.feedMessagesNotModified
        }
    
    }
}
public extension Api.help {
    enum AppUpdate: TypeConstructorDescription {
        case appUpdate(flags: Int32, id: Int32, version: String, text: String, entities: [Api.MessageEntity], document: Api.Document?, url: String?, sticker: Api.Document?)
        case noAppUpdate
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .appUpdate(let flags, let id, let version, let text, let entities, let document, let url, let sticker):
                    if boxed {
                        buffer.appendInt32(-860107216)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(id, buffer: buffer, boxed: false)
                    serializeString(version, buffer: buffer, boxed: false)
                    serializeString(text, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(entities.count))
                    for item in entities {
                        item.serialize(buffer, true)
                    }
                    if Int(flags) & Int(1 << 1) != 0 {document!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 2) != 0 {serializeString(url!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 3) != 0 {sticker!.serialize(buffer, true)}
                    break
                case .noAppUpdate:
                    if boxed {
                        buffer.appendInt32(-1000708810)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .appUpdate(let flags, let id, let version, let text, let entities, let document, let url, let sticker):
                return ("appUpdate", [("flags", String(describing: flags)), ("id", String(describing: id)), ("version", String(describing: version)), ("text", String(describing: text)), ("entities", String(describing: entities)), ("document", String(describing: document)), ("url", String(describing: url)), ("sticker", String(describing: sticker))])
                case .noAppUpdate:
                return ("noAppUpdate", [])
    }
    }
    
        public static func parse_appUpdate(_ reader: BufferReader) -> AppUpdate? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: String?
            _3 = parseString(reader)
            var _4: String?
            _4 = parseString(reader)
            var _5: [Api.MessageEntity]?
            if let _ = reader.readInt32() {
                _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.MessageEntity.self)
            }
            var _6: Api.Document?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _6 = Api.parse(reader, signature: signature) as? Api.Document
            } }
            var _7: String?
            if Int(_1!) & Int(1 << 2) != 0 {_7 = parseString(reader) }
            var _8: Api.Document?
            if Int(_1!) & Int(1 << 3) != 0 {if let signature = reader.readInt32() {
                _8 = Api.parse(reader, signature: signature) as? Api.Document
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = (Int(_1!) & Int(1 << 1) == 0) || _6 != nil
            let _c7 = (Int(_1!) & Int(1 << 2) == 0) || _7 != nil
            let _c8 = (Int(_1!) & Int(1 << 3) == 0) || _8 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 {
                return Api.help.AppUpdate.appUpdate(flags: _1!, id: _2!, version: _3!, text: _4!, entities: _5!, document: _6, url: _7, sticker: _8)
            }
            else {
                return nil
            }
        }
        public static func parse_noAppUpdate(_ reader: BufferReader) -> AppUpdate? {
            return Api.help.AppUpdate.noAppUpdate
        }
    
    }
}
public extension Api.help {
    enum CountriesList: TypeConstructorDescription {
        case countriesList(countries: [Api.help.Country], hash: Int32)
        case countriesListNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .countriesList(let countries, let hash):
                    if boxed {
                        buffer.appendInt32(-2016381538)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(countries.count))
                    for item in countries {
                        item.serialize(buffer, true)
                    }
                    serializeInt32(hash, buffer: buffer, boxed: false)
                    break
                case .countriesListNotModified:
                    if boxed {
                        buffer.appendInt32(-1815339214)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .countriesList(let countries, let hash):
                return ("countriesList", [("countries", String(describing: countries)), ("hash", String(describing: hash))])
                case .countriesListNotModified:
                return ("countriesListNotModified", [])
    }
    }
    
        public static func parse_countriesList(_ reader: BufferReader) -> CountriesList? {
            var _1: [Api.help.Country]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.help.Country.self)
            }
            var _2: Int32?
            _2 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.help.CountriesList.countriesList(countries: _1!, hash: _2!)
            }
            else {
                return nil
            }
        }
        public static func parse_countriesListNotModified(_ reader: BufferReader) -> CountriesList? {
            return Api.help.CountriesList.countriesListNotModified
        }
    
    }
}
public extension Api.help {
    enum Country: TypeConstructorDescription {
        case country(flags: Int32, iso2: String, defaultName: String, name: String?, countryCodes: [Api.help.CountryCode])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .country(let flags, let iso2, let defaultName, let name, let countryCodes):
                    if boxed {
                        buffer.appendInt32(-1014526429)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(iso2, buffer: buffer, boxed: false)
                    serializeString(defaultName, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 1) != 0 {serializeString(name!, buffer: buffer, boxed: false)}
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(countryCodes.count))
                    for item in countryCodes {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .country(let flags, let iso2, let defaultName, let name, let countryCodes):
                return ("country", [("flags", String(describing: flags)), ("iso2", String(describing: iso2)), ("defaultName", String(describing: defaultName)), ("name", String(describing: name)), ("countryCodes", String(describing: countryCodes))])
    }
    }
    
        public static func parse_country(_ reader: BufferReader) -> Country? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: String?
            _3 = parseString(reader)
            var _4: String?
            if Int(_1!) & Int(1 << 1) != 0 {_4 = parseString(reader) }
            var _5: [Api.help.CountryCode]?
            if let _ = reader.readInt32() {
                _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.help.CountryCode.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 1) == 0) || _4 != nil
            let _c5 = _5 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 {
                return Api.help.Country.country(flags: _1!, iso2: _2!, defaultName: _3!, name: _4, countryCodes: _5!)
            }
            else {
                return nil
            }
        }
    
    }
}
