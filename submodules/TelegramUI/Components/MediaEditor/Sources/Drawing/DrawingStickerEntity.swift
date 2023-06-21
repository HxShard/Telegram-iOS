import Foundation
import UIKit
import Display
import AccountContext
import TelegramCore

public final class DrawingStickerEntity: DrawingEntity, Codable {
    public enum Content: Equatable {
        case file(TelegramMediaFile)
        case image(UIImage)
        case video(String, UIImage?)
        
        public static func == (lhs: Content, rhs: Content) -> Bool {
            switch lhs {
            case let .file(lhsFile):
                if case let .file(rhsFile) = rhs {
                    return lhsFile.fileId == rhsFile.fileId
                } else {
                    return false
                }
            case let .image(lhsImage):
                if case let .image(rhsImage) = rhs {
                    return lhsImage === rhsImage
                } else {
                    return false
                }
            case let .video(lhsPath, _):
                if case let .video(rhsPath, _) = rhs {
                    return lhsPath == rhsPath
                } else {
                    return false
                }
            }
        }
    }
    private enum CodingKeys: String, CodingKey {
        case uuid
        case file
        case image
        case videoPath
        case videoImage
        case referenceDrawingSize
        case position
        case scale
        case rotation
        case mirrored
    }
    
    public let uuid: UUID
    public let content: Content
    
    public var referenceDrawingSize: CGSize
    public var position: CGPoint
    public var scale: CGFloat
    public var rotation: CGFloat
    public var mirrored: Bool
    
    public var color: DrawingColor = DrawingColor.clear
    public var lineWidth: CGFloat = 0.0
    
    public var center: CGPoint {
        return self.position
    }
    
    public var baseSize: CGSize {
        let size = max(10.0, min(self.referenceDrawingSize.width, self.referenceDrawingSize.height) * 0.25)
        return CGSize(width: size, height: size)
    }
    
    public var isAnimated: Bool {
        switch self.content {
        case let .file(file):
            return file.isAnimatedSticker || file.isVideoSticker || file.mimeType == "video/webm"
        case .image:
            return false
        case .video:
            return true
        }
    }
    
    public var isMedia: Bool {
        return false
    }
    
    public var renderImage: UIImage?
    public var renderSubEntities: [DrawingEntity]?
    
    public init(content: Content) {
        self.uuid = UUID()
        self.content = content
        
        self.referenceDrawingSize = .zero
        self.position = CGPoint()
        self.scale = 1.0
        self.rotation = 0.0
        self.mirrored = false
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        if let file = try container.decodeIfPresent(TelegramMediaFile.self, forKey: .file) {
            self.content = .file(file)
        } else if let imageData = try container.decodeIfPresent(Data.self, forKey: .image), let image = UIImage(data: imageData) {
            self.content = .image(image)
        } else if let videoPath = try container.decodeIfPresent(String.self, forKey: .videoPath) {
            var imageValue: UIImage?
            if let imageData = try container.decodeIfPresent(Data.self, forKey: .image), let image = UIImage(data: imageData) {
                imageValue = image
            }
            self.content = .video(videoPath, imageValue)
        } else {
            fatalError()
        }
        self.referenceDrawingSize = try container.decode(CGSize.self, forKey: .referenceDrawingSize)
        self.position = try container.decode(CGPoint.self, forKey: .position)
        self.scale = try container.decode(CGFloat.self, forKey: .scale)
        self.rotation = try container.decode(CGFloat.self, forKey: .rotation)
        self.mirrored = try container.decode(Bool.self, forKey: .mirrored)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uuid, forKey: .uuid)
        switch self.content {
        case let .file(file):
            try container.encode(file, forKey: .file)
        case let .image(image):
            try container.encodeIfPresent(image.pngData(), forKey: .image)
        case let .video(path, image):
            try container.encode(path, forKey: .videoPath)
            try container.encodeIfPresent(image?.jpegData(compressionQuality: 0.87), forKey: .videoImage)
        }
        try container.encode(self.referenceDrawingSize, forKey: .referenceDrawingSize)
        try container.encode(self.position, forKey: .position)
        try container.encode(self.scale, forKey: .scale)
        try container.encode(self.rotation, forKey: .rotation)
        try container.encode(self.mirrored, forKey: .mirrored)
    }
        
    public func duplicate() -> DrawingEntity {
        let newEntity = DrawingStickerEntity(content: self.content)
        newEntity.referenceDrawingSize = self.referenceDrawingSize
        newEntity.position = self.position
        newEntity.scale = self.scale
        newEntity.rotation = self.rotation
        newEntity.mirrored = self.mirrored
        return newEntity
    }
    
    public func isEqual(to other: DrawingEntity) -> Bool {
        guard let other = other as? DrawingStickerEntity else {
            return false
        }
        if self.uuid != other.uuid {
            return false
        }
        if self.content != other.content {
            return false
        }
        if self.referenceDrawingSize != other.referenceDrawingSize {
            return false
        }
        if self.position != other.position {
            return false
        }
        if self.scale != other.scale {
            return false
        }
        if self.rotation != other.rotation {
            return false
        }
        if self.mirrored != other.mirrored {
            return false
        }
        return true
    }
}
