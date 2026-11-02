//
//  OthersView.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct OthersView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    
    var body: some View {
        Group {
            switch dataManager.router.getLast() {
            case .about:
                AboutView()
            case .toolbox:
                ToolboxView()
            case .debug:
                DebugView()
            default:
                // 兜底：纯根路由（理论上 setRoot 已预置默认子路由，不会走到这里）
                AboutView()
                    .onAppear {
                        if dataManager.router.getLast() == .others {
                            dataManager.router.append(.about)
                        }
                    }
            }
        }
        .onAppear {
            dataManager.leftTab(140, expectedRoot: .others) {
                VStack(alignment: .leading, spacing: 0) {
                    MyList(
                        root: .others,
                        cases: .constant(SharedConstants.shared.isDevelopment ? [.about, .toolbox, .debug] : [.about, .toolbox])
                    ) { type, isSelected in
                        createListItemView(type)
                            .foregroundStyle(isSelected ? AnyShapeStyle(AppSettings.shared.theme.getTextStyle()) : AnyShapeStyle(Color("TextColor")))
                    }
                    .id("OthersList")
                    .padding(.top, 10)
                    Spacer()
                }
            }
        }
    }
    
    private func createListItemView(_ lastComponent: AppRoute) -> some View {
        var imageName: String
        var text: String
        
        switch lastComponent {
        case .about:
            imageName = "AboutIcon"
            text = "关于与鸣谢"
        case .toolbox:
            imageName = "BoxIcon"
            text = "百宝箱"
        case .debug:
            imageName = "InstallWaiting"
            text = "调试"
        default:
            return AnyView(EmptyView())
        }
        
        return AnyView(
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.custom("PCL English", size: 14))
            }
        )
    }
}
