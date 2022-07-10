//
//  AboutView.swift
//  WMO
//
//  Created by weijia on 2022/6/2.
//

import SwiftUI

private let toolbarItemSize: CGFloat = 15

struct AboutView: View {

    struct Row {
        let title: String
        let link: String
        let detail: String
    }

    typealias AboutSection = (title: String, rows: [Row])
    private let aboutSections: [AboutSection] = [
        (title: "社交媒体", rows: [
            .init(title: "📝 博客", link: "https://blog.womenoverseas.com", detail: ""),
            .init(title: "👤 公众号", link: "https://mp.weixin.qq.com/s?__biz=MzAwMTMyNjA1Nw==&mid=2451850815&idx=1&sn=fe03c92f701f50306a513e9194ad2746&chksm=8d0b88b9ba7c01af2cda70bf1834ba68cd46892d640a7920bc3912fd1b64d57b5cbb56c65678&token=562956425&lang=zh_CN#rd", detail: "@womenoverseas"),
            .init(title: "📕 小红书", link: "https://www.xiaohongshu.com/user/profile/604595aa0000000001004db3?xhsshare=CopyLink&appuid=5ba493a1bcc119000128062f&apptime=1615355488", detail: "@WomenOverseas 她乡"),
            .init(title: "📻 播客", link: "https://pod.link/1549407631", detail: "@WomenOverseas她乡电台"),
            .init(title: "👁‍🗨 微博", link: "https://weibo.com/u/7574581372?refer_flag=1005055010_&is_all=1", detail: "@WomenOverseas_她乡"),
        ]),
        (title: "关于她乡", rows: [
            // .init(title: "捐助", link: "https://womenoverseas.com/t/topic/11426", detail: ""),
            .init(title: "常见问题", link: "https://womenoverseas.com/faq", detail: ""),
            .init(title: "公开账目", link: "https://womenoverseas.com/t/topic/13901", detail: ""),
            .init(title: "站点反馈", link: "https://womenoverseas.com/t/topic/291", detail: ""),
            .init(title: "隐私条款", link: "https://womenoverseas.com/privacy", detail: ""),
        ]),
    ]

    private let socialMedia: [(icon: String, link: String)] = [
        ("gmail", "mailto:womenoverseas.taxiang@gmail.com"),
        ("wechat", "https://mp.weixin.qq.com/s/XqM5cdW_q0XeX7X-zXErYA"),
        ("telegram", "https://t.me/womenoverseas"),
        ("youtube", "https://www.youtube.com/channel/UCFDELGqbjkz9v2vGM0d6HfA"),
        ("instagram", "https://www.instagram.com/womenoverseas/"),
    ]

    var body: some View {
        Form {
            mainIcon()
            Section(header: Text(aboutSections[0].title)) {
                ForEach(aboutSections[0].rows, id: \.title) { row in
                    Button {
                        if let url = URL(string: row.link) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        self.row(row)
                    }
                }
            }
            Section(header: Text(aboutSections[1].title)) {
                ForEach(aboutSections[1].rows, id: \.title) { row in
                    NavigationLink(destination: Webview(type: .home, url: row.link)) {
                        self.row(row, noIndicator: true)
                    }
                }
            }
            socialMediaButtons()
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.systemGroup)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("关于我们")
                    .font(.system(size: toolbarItemSize, weight: .semibold))
                    .foregroundColor(Color.black)
            }
        }
    }

    @ViewBuilder
    func mainIcon() -> some View {
        HStack {
            Spacer()
            Image("wo_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
            Spacer()
        }
        .listRowBackground(Color.systemGroup)
    }

    @ViewBuilder
    private func socialMediaButtons() -> some View {
        HStack(spacing: 20) {
            Spacer()
            ForEach(self.socialMedia, id: \.icon) { item in
                Image(item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .onTapGesture {
                        print("socialMeida click \(item.icon) \(item.link)")
                        if let url = URL(string: item.link) {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            Spacer()
        }
        .listRowBackground(Color.systemGroup)
    }

    @ViewBuilder
    private func row(_ row: Row, noIndicator: Bool = false) -> some View {
        HStack {
            Text(row.title)
                .foregroundColor(Color.black)
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Text(row.detail)
                .foregroundColor(Color.gray)
                .font(.system(size: 13))
            if !noIndicator {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
        }
    }
}

#if DEBUG
struct AboutView_Previews : PreviewProvider {
    static var previews: some View {
        AboutView()
//            .environment(\.colorScheme, .dark)
    }
}
#endif
