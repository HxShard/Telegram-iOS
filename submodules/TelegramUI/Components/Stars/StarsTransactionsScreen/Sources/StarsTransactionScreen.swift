import Foundation
import UIKit
import Display
import AsyncDisplayKit
import TelegramCore
import SwiftSignalKit
import AccountContext
import TelegramPresentationData
import PresentationDataUtils
import ComponentFlow
import ViewControllerComponent
import SheetComponent
import MultilineTextComponent
import BundleIconComponent
import SolidRoundedButtonComponent
import Markdown
import BalancedTextComponent
import AvatarNode
import TextFormat
import TelegramStringFormatting
import UndoUI
import PremiumStarComponent

private final class StarsTransactionSheetContent: CombinedComponent {
    typealias EnvironmentType = ViewControllerComponentContainer.Environment
    
    let context: AccountContext
    let subject: StarsTransactionScreen.Subject
    let action: () -> Void
    let cancel: (Bool) -> Void
    let openPeer: (EnginePeer) -> Void
    
    init(
        context: AccountContext,
        subject: StarsTransactionScreen.Subject,
        action: @escaping () -> Void,
        cancel: @escaping  (Bool) -> Void,
        openPeer: @escaping (EnginePeer) -> Void
    ) {
        self.context = context
        self.subject = subject
        self.action = action
        self.cancel = cancel
        self.openPeer = openPeer
    }
    
    static func ==(lhs: StarsTransactionSheetContent, rhs: StarsTransactionSheetContent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.subject != rhs.subject {
            return false
        }
        return true
    }
    
    final class State: ComponentState {
        private let context: AccountContext
        private var disposable: Disposable?
        var initialized = false
        
        var peerMap: [EnginePeer.Id: EnginePeer] = [:]
        
        var cachedCloseImage: (UIImage, PresentationTheme)?
        
        var inProgress = false
        
        init(context: AccountContext, subject: StarsTransactionScreen.Subject) {
            self.context = context
            
            super.init()
            
            var peerIds: [EnginePeer.Id] = []
            switch subject {
            case let .transaction(transaction):
                if case let .peer(peer) = transaction.peer {
                    peerIds.append(peer.id)
                }
            }
            
            self.disposable = (context.engine.data.get(
                EngineDataMap(
                    peerIds.map { peerId -> TelegramEngine.EngineData.Item.Peer.Peer in
                        return TelegramEngine.EngineData.Item.Peer.Peer(id: peerId)
                    }
                )
            ) |> deliverOnMainQueue).startStrict(next: { [weak self] peers in
                if let strongSelf = self {
                    var peersMap: [EnginePeer.Id: EnginePeer] = [:]
                    for peerId in peerIds {
                        if let maybePeer = peers[peerId], let peer = maybePeer {
                            peersMap[peerId] = peer
                        }
                    }
                    strongSelf.peerMap = peersMap
                    strongSelf.initialized = true
                
                    strongSelf.updated(transition: .immediate)
                }
            })
        }
        
        deinit {
            self.disposable?.dispose()
        }
    }
    
    func makeState() -> State {
        return State(context: self.context, subject: self.subject)
    }
    
    static var body: Body {
        let closeButton = Child(Button.self)
        let title = Child(MultilineTextComponent.self)
        let star = Child(GiftAvatarComponent.self)
        let description = Child(BalancedTextComponent.self)
        let table = Child(TableComponent.self)
        let additional = Child(BalancedTextComponent.self)
        let button = Child(SolidRoundedButtonComponent.self)
        
        return { context in
            let environment = context.environment[ViewControllerComponentContainer.Environment.self].value
            let component = context.component
            let theme = environment.theme
            let strings = environment.strings
            let dateTimeFormat = environment.dateTimeFormat
            let accountContext = context.component.context
            
            let state = context.state
            let subject = component.subject
            
            let sideInset: CGFloat = 16.0 + environment.safeInsets.left
            let textSideInset: CGFloat = 32.0 + environment.safeInsets.left
            
            let closeImage: UIImage
            if let (image, theme) = state.cachedCloseImage, theme === environment.theme {
                closeImage = image
            } else {
                closeImage = generateCloseButtonImage(backgroundColor: UIColor(rgb: 0x808084, alpha: 0.1), foregroundColor: theme.actionSheet.inputClearButtonColor)!
                state.cachedCloseImage = (closeImage, theme)
            }
            
            let closeButton = closeButton.update(
                component: Button(
                    content: AnyComponent(Image(image: closeImage)),
                    action: { [weak component] in
                        component?.cancel(true)
                    }
                ),
                availableSize: CGSize(width: 30.0, height: 30.0),
                transition: .immediate
            )
            
            let titleText: String
            let descriptionText: String
            let additionalText: String
            let buttonText: String
            
            let transactionId: String
            let date: Int32
            let toPeer: EnginePeer?
            
            let gloss = false
            switch subject {
            case let .transaction(transaction):
                titleText = "Product Title"
                if transaction.count < 0 {
                    descriptionText = "- \(transaction.count * -1) ⭐️"
                } else {
                    descriptionText = "+ \(transaction.count) ⭐️"
                }
                additionalText = strings.Stars_Transaction_Terms
                buttonText = strings.Common_OK
                
                transactionId = transaction.id
                date = transaction.date
                if case let .peer(peer) = transaction.peer {
                    toPeer = peer
                } else {
                    toPeer = nil
                }
            }
            
            let title = title.update(
                component: MultilineTextComponent(
                    text: .plain(NSAttributedString(
                        string: titleText,
                        font: Font.semibold(24.0),
                        textColor: theme.actionSheet.primaryTextColor,
                        paragraphAlignment: .center
                    )),
                    horizontalAlignment: .center,
                    maximumNumberOfLines: 1
                ),
                availableSize: CGSize(width: context.availableSize.width - sideInset * 2.0 - 60.0, height: CGFloat.greatestFiniteMagnitude),
                transition: .immediate
            )
            
            let star = star.update(
                component: GiftAvatarComponent(
                    context: component.context,
                    theme: theme,
                    peers: toPeer.flatMap { [$0] } ?? [],
                    isVisible: true,
                    hasIdleAnimations: true,
                    hasScaleAnimation: false,
                    avatarSize: 90.0,
                    color: UIColor(rgb: 0xf7ab04)
                ),
                availableSize: CGSize(width: context.availableSize.width, height: 200.0),
                transition: .immediate
            )
            
            let textFont = Font.regular(15.0)
            let boldTextFont = Font.semibold(15.0)
            let textColor = theme.actionSheet.primaryTextColor
            let linkColor = theme.actionSheet.controlAccentColor
            let markdownAttributes = MarkdownAttributes(body: MarkdownAttributeSet(font: textFont, textColor: textColor), bold: MarkdownAttributeSet(font: boldTextFont, textColor: textColor), link: MarkdownAttributeSet(font: textFont, textColor: linkColor), linkAttribute: { contents in
                return (TelegramTextAttributes.URL, contents)
            })
            let description = description.update(
                component: BalancedTextComponent(
                    text: .plain(NSAttributedString(string: descriptionText, font: boldTextFont, textColor: descriptionText.hasPrefix("-") ? theme.list.itemDestructiveColor : theme.list.itemDisclosureActions.constructive.fillColor)),
                    horizontalAlignment: .center,
                    maximumNumberOfLines: 0,
                    lineSpacing: 0.2
                ),
                availableSize: CGSize(width: context.availableSize.width - textSideInset * 2.0, height: context.availableSize.height),
                transition: .immediate
            )
             
            let tableFont = Font.regular(15.0)
            let tableTextColor = theme.list.itemPrimaryTextColor
            let tableLinkColor = theme.list.itemAccentColor
            var tableItems: [TableComponent.Item] = []
                        
            if let toPeer {
                tableItems.append(.init(
                    id: "to",
                    title: strings.Stars_Transaction_Date,
                    component: AnyComponent(
                        Button(
                            content: AnyComponent(PeerCellComponent(context: context.component.context, textColor: tableLinkColor, peer: toPeer)),
                            action: {
                                if toPeer.id != accountContext.account.peerId {
                                    component.openPeer(toPeer)
                                    Queue.mainQueue().after(1.0, {
                                        component.cancel(false)
                                    })
                                }
                            }
                        )
                    )
                ))
            }

            tableItems.append(.init(
                id: "transaction",
                title: strings.Stars_Transaction_Id,
                component: AnyComponent(
                    MultilineTextComponent(
                        text: .plain(NSAttributedString(string: transactionId, font: Font.monospace(15.0), textColor: tableTextColor)),
                        truncationType: .end,
                        maximumNumberOfLines: 0
                    )
                )
            ))
            
            tableItems.append(.init(
                id: "date",
                title: strings.Stars_Transaction_Date,
                component: AnyComponent(
                    MultilineTextComponent(text: .plain(NSAttributedString(string: stringForMediumDate(timestamp: date, strings: strings, dateTimeFormat: dateTimeFormat), font: tableFont, textColor: tableTextColor)))
                )
            ))
            
            let table = table.update(
                component: TableComponent(
                    theme: environment.theme,
                    items: tableItems
                ),
                availableSize: CGSize(width: context.availableSize.width - sideInset * 2.0, height: .greatestFiniteMagnitude),
                transition: .immediate
            )
            
            let additional = additional.update(
                component: BalancedTextComponent(
                    text: .markdown(text: additionalText, attributes: markdownAttributes),
                    horizontalAlignment: .center,
                    maximumNumberOfLines: 0,
                    lineSpacing: 0.1,
                    highlightColor: linkColor.withAlphaComponent(0.2),
                    highlightAction: { attributes in
                        if let _ = attributes[NSAttributedString.Key(rawValue: TelegramTextAttributes.URL)] {
                            return NSAttributedString.Key(rawValue: TelegramTextAttributes.URL)
                        } else {
                            return nil
                        }
                    },
                    tapAction: { attributes, _ in
                        let presentationData = component.context.sharedContext.currentPresentationData.with { $0 }
                        component.context.sharedContext.openExternalUrl(context: component.context, urlContext: .generic, url: strings.Stars_Transaction_Terms_URL, forceExternal: true, presentationData: presentationData, navigationController: nil, dismissInput: {})
                    }
                ),
                availableSize: CGSize(width: context.availableSize.width - textSideInset * 2.0, height: context.availableSize.height),
                transition: .immediate
            )
          
            let button = button.update(
                component: SolidRoundedButtonComponent(
                    title: buttonText,
                    theme: SolidRoundedButtonComponent.Theme(theme: theme),
                    font: .bold,
                    fontSize: 17.0,
                    height: 50.0,
                    cornerRadius: 10.0,
                    gloss: gloss,
                    iconName: nil,
                    animationName: nil,
                    iconPosition: .left,
                    isLoading: state.inProgress,
                    action: { [weak state] in
                        if gloss {
                            component.action()
                            if let state {
                                state.inProgress = true
                                state.updated()
                            }
                        } else {
                            component.cancel(true)
                        }
                    }
                ),
                availableSize: CGSize(width: context.availableSize.width - sideInset * 2.0, height: 50.0),
                transition: context.transition
            )
            
            context.add(title
                .position(CGPoint(x: context.availableSize.width / 2.0, y: 28.0 + 125.0))
            )
            
            context.add(star
                .position(CGPoint(x: context.availableSize.width / 2.0, y: star.size.height / 2.0 - 32.0))
            )
            
            var originY: CGFloat = 0.0
            originY += star.size.height - 32.0
            
            context.add(description
                .position(CGPoint(x: context.availableSize.width / 2.0, y: originY + description.size.height / 2.0))
            )
            originY += description.size.height + 21.0
                        
            context.add(table
                .position(CGPoint(x: context.availableSize.width / 2.0, y: originY + table.size.height / 2.0))
            )
            originY += table.size.height + 23.0
            
            context.add(additional
                .position(CGPoint(x: context.availableSize.width / 2.0, y: originY + additional.size.height / 2.0))
            )
            originY += additional.size.height + 23.0
            
            let buttonFrame = CGRect(origin: CGPoint(x: sideInset, y: originY), size: button.size)
            context.add(button
                .position(CGPoint(x: buttonFrame.midX, y: buttonFrame.midY))
            )
            
            context.add(closeButton
                .position(CGPoint(x: context.availableSize.width - environment.safeInsets.left - closeButton.size.width, y: 28.0))
            )
            
            let contentSize = CGSize(width: context.availableSize.width, height: buttonFrame.maxY + 5.0 + environment.safeInsets.bottom)
        
            return contentSize
        }
    }
}

private final class StarsTransactionSheetComponent: CombinedComponent {
    typealias EnvironmentType = ViewControllerComponentContainer.Environment
    
    let context: AccountContext
    let subject: StarsTransactionScreen.Subject
    let action: () -> Void
    let openPeer: (EnginePeer) -> Void
    
    init(
        context: AccountContext,
        subject: StarsTransactionScreen.Subject,
        action: @escaping () -> Void,
        openPeer: @escaping (EnginePeer) -> Void
    ) {
        self.context = context
        self.subject = subject
        self.action = action
        self.openPeer = openPeer
    }
    
    static func ==(lhs: StarsTransactionSheetComponent, rhs: StarsTransactionSheetComponent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.subject != rhs.subject {
            return false
        }
        return true
    }
    
    static var body: Body {
        let sheet = Child(SheetComponent<EnvironmentType>.self)
        let animateOut = StoredActionSlot(Action<Void>.self)
        
        return { context in
            let environment = context.environment[EnvironmentType.self]
            let controller = environment.controller
            
            let sheet = sheet.update(
                component: SheetComponent<EnvironmentType>(
                    content: AnyComponent<EnvironmentType>(StarsTransactionSheetContent(
                        context: context.component.context,
                        subject: context.component.subject,
                        action: context.component.action,
                        cancel: { animate in
                            if animate {
                                animateOut.invoke(Action { _ in
                                    if let controller = controller() {
                                        controller.dismiss(completion: nil)
                                    }
                                })
                            } else if let controller = controller() {
                                controller.dismiss(animated: false, completion: nil)
                            }
                        },
                        openPeer: context.component.openPeer
                    )),
                    backgroundColor: .color(environment.theme.actionSheet.opaqueItemBackgroundColor),
                    followContentSizeChanges: true,
                    clipsContent: true,
                    animateOut: animateOut
                ),
                environment: {
                    environment
                    SheetComponentEnvironment(
                        isDisplaying: environment.value.isVisible,
                        isCentered: environment.metrics.widthClass == .regular,
                        hasInputHeight: !environment.inputHeight.isZero,
                        regularMetricsSize: CGSize(width: 430.0, height: 900.0),
                        dismiss: { animated in
                            if animated {
                                animateOut.invoke(Action { _ in
                                    if let controller = controller() {
                                        controller.dismiss(completion: nil)
                                    }
                                })
                            } else {
                                if let controller = controller() {
                                    controller.dismiss(completion: nil)
                                }
                            }
                        }
                    )
                },
                availableSize: context.availableSize,
                transition: context.transition
            )
            
            context.add(sheet
                .position(CGPoint(x: context.availableSize.width / 2.0, y: context.availableSize.height / 2.0))
            )
            
            return context.availableSize
        }
    }
}

public class StarsTransactionScreen: ViewControllerComponentContainer {
    public enum Subject: Equatable {
        case transaction(StarsContext.State.Transaction)
    }
    
    private let context: AccountContext
    public var disposed: () -> Void = {}
    
    private let hapticFeedback = HapticFeedback()
    
    public init(
        context: AccountContext,
        subject: StarsTransactionScreen.Subject,
        forceDark: Bool = false,
        action: @escaping () -> Void
    ) {
        self.context = context
        
        var openPeerImpl: ((EnginePeer) -> Void)?
        super.init(
            context: context,
            component: StarsTransactionSheetComponent(
                context: context,
                subject: subject,
                action: action,
                openPeer: { peerId in
                    openPeerImpl?(peerId)
                }
            ),
            navigationBarAppearance: .none,
            statusBarStyle: .ignore,
            theme: forceDark ? .dark : .default
        )
        
        self.navigationPresentation = .flatModal
        
        openPeerImpl = { [weak self] peer in
            guard let self, let navigationController = self.navigationController as? NavigationController else {
                return
            }
            let _ = (context.engine.data.get(
                TelegramEngine.EngineData.Item.Peer.Peer(id: peer.id)
            )
            |> deliverOnMainQueue).start(next: { peer in
                guard let peer else {
                    return
                }
                context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, chatController: nil, context: context, chatLocation: .peer(peer), subject: nil, botStart: nil, updateTextInputState: nil, keepStack: .always, useExisting: false, purposefulAction: nil, scrollToEndIfExists: false, activateMessageSearch: nil, animated: true))
            })
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.disposed()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.disablesInteractiveModalDismiss = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissAllTooltips()
    }
    
    public func dismissAnimated() {
        if let view = self.node.hostView.findTaggedView(tag: SheetComponent<ViewControllerComponentContainer.Environment>.View.Tag()) as? SheetComponent<ViewControllerComponentContainer.Environment>.View {
            view.dismissAnimated()
        }
    }
    
    fileprivate func dismissAllTooltips() {
        self.window?.forEachController({ controller in
            if let controller = controller as? UndoOverlayController {
                controller.dismiss()
            }
        })
        self.forEachController({ controller in
            if let controller = controller as? UndoOverlayController {
                controller.dismiss()
            }
            return true
        })
    }
}

private final class TableComponent: CombinedComponent {
    class Item: Equatable {
        public let id: AnyHashable
        public let title: String
        public let component: AnyComponent<Empty>

        public init<IdType: Hashable>(id: IdType, title: String, component: AnyComponent<Empty>) {
            self.id = AnyHashable(id)
            self.title = title
            self.component = component
        }

        public static func == (lhs: Item, rhs: Item) -> Bool {
            if lhs.id != rhs.id {
                return false
            }
            if lhs.title != rhs.title {
                return false
            }
            if lhs.component != rhs.component {
                return false
            }
            return true
        }
    }
    
    private let theme: PresentationTheme
    private let items: [Item]

    public init(theme: PresentationTheme, items: [Item]) {
        self.theme = theme
        self.items = items
    }

    public static func ==(lhs: TableComponent, rhs: TableComponent) -> Bool {
        if lhs.theme !== rhs.theme {
            return false
        }
        if lhs.items != rhs.items {
            return false
        }
        return true
    }
    
    final class State: ComponentState {
        var cachedBorderImage: (UIImage, PresentationTheme)?
    }
    
    func makeState() -> State {
        return State()
    }

    public static var body: Body {
        let leftColumnBackground = Child(Rectangle.self)
        let verticalBorder = Child(Rectangle.self)
        let titleChildren = ChildMap(environment: Empty.self, keyedBy: AnyHashable.self)
        let valueChildren = ChildMap(environment: Empty.self, keyedBy: AnyHashable.self)
        let borderChildren = ChildMap(environment: Empty.self, keyedBy: AnyHashable.self)
        let outerBorder = Child(Image.self)

        return { context in
            let verticalPadding: CGFloat = 11.0
            let horizontalPadding: CGFloat = 12.0
            let borderWidth: CGFloat = 1.0
            
            let backgroundColor = context.component.theme.actionSheet.opaqueItemBackgroundColor
            let borderColor = backgroundColor.mixedWith(context.component.theme.list.itemBlocksSeparatorColor, alpha: 0.6)
            
            var leftColumnWidth: CGFloat = 0.0
            
            var updatedTitleChildren: [_UpdatedChildComponent] = []
            var updatedValueChildren: [_UpdatedChildComponent] = []
            var updatedBorderChildren: [_UpdatedChildComponent] = []
            
            for item in context.component.items {
                let titleChild = titleChildren[item.id].update(
                    component: AnyComponent(MultilineTextComponent(
                        text: .plain(NSAttributedString(string: item.title, font: Font.regular(15.0), textColor: context.component.theme.list.itemPrimaryTextColor))
                    )),
                    availableSize: context.availableSize,
                    transition: context.transition
                )
                updatedTitleChildren.append(titleChild)
                
                if titleChild.size.width > leftColumnWidth {
                    leftColumnWidth = titleChild.size.width
                }
            }
            
            leftColumnWidth = max(100.0, leftColumnWidth + horizontalPadding * 2.0)
            let rightColumnWidth = context.availableSize.width - leftColumnWidth
            
            var i = 0
            var rowHeights: [Int: CGFloat] = [:]
            var totalHeight: CGFloat = 0.0
            
            for item in context.component.items {
                let titleChild = updatedTitleChildren[i]
                let valueChild = valueChildren[item.id].update(
                    component: item.component,
                    availableSize: CGSize(width: rightColumnWidth - horizontalPadding * 2.0, height: context.availableSize.height),
                    transition: context.transition
                )
                updatedValueChildren.append(valueChild)
                
                let rowHeight = max(40.0, max(titleChild.size.height, valueChild.size.height) + verticalPadding * 2.0)
                rowHeights[i] = rowHeight
                totalHeight += rowHeight
                
                if i < context.component.items.count - 1 {
                    let borderChild = borderChildren[item.id].update(
                        component: AnyComponent(Rectangle(color: borderColor)),
                        availableSize: CGSize(width: context.availableSize.width, height: borderWidth),
                        transition: context.transition
                    )
                    updatedBorderChildren.append(borderChild)
                }
                
                i += 1
            }
            
            let leftColumnBackground = leftColumnBackground.update(
                component: Rectangle(color: context.component.theme.list.itemInputField.backgroundColor),
                availableSize: CGSize(width: leftColumnWidth, height: totalHeight),
                transition: context.transition
            )
            context.add(
                leftColumnBackground
                    .position(CGPoint(x: leftColumnWidth / 2.0, y: totalHeight / 2.0))
            )
            
            let borderImage: UIImage
            if let (currentImage, theme) = context.state.cachedBorderImage, theme === context.component.theme {
                borderImage = currentImage
            } else {
                let borderRadius: CGFloat = 5.0
                borderImage = generateImage(CGSize(width: 16.0, height: 16.0), rotatedContext: { size, context in
                    let bounds = CGRect(origin: .zero, size: size)
                    context.setFillColor(backgroundColor.cgColor)
                    context.fill(bounds)
                    
                    let path = CGPath(roundedRect: bounds.insetBy(dx: borderWidth / 2.0, dy: borderWidth / 2.0), cornerWidth: borderRadius, cornerHeight: borderRadius, transform: nil)
                    context.setBlendMode(.clear)
                    context.addPath(path)
                    context.fillPath()
                    
                    context.setBlendMode(.normal)
                    context.setStrokeColor(borderColor.cgColor)
                    context.setLineWidth(borderWidth)
                    context.addPath(path)
                    context.strokePath()
                })!.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5)
                context.state.cachedBorderImage = (borderImage, context.component.theme)
            }
            
            let outerBorder = outerBorder.update(
                component: Image(image: borderImage),
                availableSize: CGSize(width: context.availableSize.width, height: totalHeight),
                transition: context.transition
            )
            context.add(outerBorder
                .position(CGPoint(x: context.availableSize.width / 2.0, y: totalHeight / 2.0))
            )
            
            let verticalBorder = verticalBorder.update(
                component: Rectangle(color: borderColor),
                availableSize: CGSize(width: borderWidth, height: totalHeight),
                transition: context.transition
            )
            context.add(
                verticalBorder
                    .position(CGPoint(x: leftColumnWidth - borderWidth / 2.0, y: totalHeight / 2.0))
            )
            
            i = 0
            var originY: CGFloat = 0.0
            for (titleChild, valueChild) in zip(updatedTitleChildren, updatedValueChildren) {
                let rowHeight = rowHeights[i] ?? 0.0
                
                let titleFrame = CGRect(origin: CGPoint(x: horizontalPadding, y: originY + verticalPadding), size: titleChild.size)
                let valueFrame = CGRect(origin: CGPoint(x: leftColumnWidth + horizontalPadding, y: originY + verticalPadding), size: valueChild.size)
                
                context.add(titleChild
                    .position(titleFrame.center)
                )
                
                context.add(valueChild
                    .position(valueFrame.center)
                )
                
                if i < updatedBorderChildren.count {
                    let borderChild = updatedBorderChildren[i]
                    context.add(borderChild
                        .position(CGPoint(x: context.availableSize.width / 2.0, y: originY + rowHeight - borderWidth / 2.0))
                    )
                }
                
                originY += rowHeight
                i += 1
            }
            
            return CGSize(width: context.availableSize.width, height: totalHeight)
        }
    }
}

private final class PeerCellComponent: Component {
    let context: AccountContext
    let textColor: UIColor
    let peer: EnginePeer?

    init(context: AccountContext, textColor: UIColor, peer: EnginePeer?) {
        self.context = context
        self.textColor = textColor
        self.peer = peer
    }

    static func ==(lhs: PeerCellComponent, rhs: PeerCellComponent) -> Bool {
        if lhs.context !== rhs.context {
            return false
        }
        if lhs.textColor !== rhs.textColor {
            return false
        }
        if lhs.peer != rhs.peer {
            return false
        }
        return true
    }

    final class View: UIView {
        private let avatarNode: AvatarNode
        private let text = ComponentView<Empty>()
                
        private var component: PeerCellComponent?
        private weak var state: EmptyComponentState?
        
        override init(frame: CGRect) {
            self.avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 13.0))
            
            super.init(frame: frame)
            
            self.addSubnode(self.avatarNode)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(component: PeerCellComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
            self.component = component
            self.state = state
                                    
            self.avatarNode.setPeer(
                context: component.context,
                theme: component.context.sharedContext.currentPresentationData.with({ $0 }).theme,
                peer: component.peer,
                synchronousLoad: true
            )
            
            let avatarSize = CGSize(width: 22.0, height: 22.0)
            let spacing: CGFloat = 6.0
            
            let textSize = self.text.update(
                transition: .immediate,
                component: AnyComponent(
                    MultilineTextComponent(
                        text: .plain(NSAttributedString(string: component.peer?.compactDisplayTitle ?? "", font: Font.regular(15.0), textColor: component.textColor, paragraphAlignment: .left))
                    )
                ),
                environment: {},
                containerSize: CGSize(width: availableSize.width - avatarSize.width - spacing, height: availableSize.height)
            )
            
            let size = CGSize(width: avatarSize.width + textSize.width + spacing, height: textSize.height)
            
            let avatarFrame = CGRect(origin: CGPoint(x: 0.0, y: floorToScreenPixels((size.height - avatarSize.height) / 2.0)), size: avatarSize)
            self.avatarNode.frame = avatarFrame
            
            if let view = self.text.view {
                if view.superview == nil {
                    self.addSubview(view)
                }
                let textFrame = CGRect(origin: CGPoint(x: avatarSize.width + spacing, y: floorToScreenPixels((size.height - textSize.height) / 2.0)), size: textSize)
                transition.setFrame(view: view, frame: textFrame)
            }
            
            return size
        }
    }

    func makeView() -> View {
        return View(frame: CGRect())
    }

    func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}


private func generateCloseButtonImage(backgroundColor: UIColor, foregroundColor: UIColor) -> UIImage? {
    return generateImage(CGSize(width: 30.0, height: 30.0), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        
        context.setFillColor(backgroundColor.cgColor)
        context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
        
        context.setLineWidth(2.0)
        context.setLineCap(.round)
        context.setStrokeColor(foregroundColor.cgColor)
        
        context.move(to: CGPoint(x: 10.0, y: 10.0))
        context.addLine(to: CGPoint(x: 20.0, y: 20.0))
        context.strokePath()
        
        context.move(to: CGPoint(x: 20.0, y: 10.0))
        context.addLine(to: CGPoint(x: 10.0, y: 20.0))
        context.strokePath()
    })
}
