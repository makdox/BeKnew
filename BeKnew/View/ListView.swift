
import SwiftUI

struct WindowView: View {
    var article: Articles
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title ?? "")
                .font(.title)
                .fontWeight(.bold)
            
            Text(article.description ?? "")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                
                Text(article.publishedAt ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ListView: View {
    
    @State var articles: [Articles] = []
    @State var model: Model!
    @State private var resultArray: [Articles] = []
    @State var changedValue = "Apple"
    let spaceChanger = "%20"
    let space = " "
    @StateObject private var api = Api()
    @State private var searchText = ""
    @State var authorName = ""
    
    
    var body: some View {
        NavigationView {
            List(articles, id: \.id) { (article) in
                NavigationLink(destination: MoreView(article: article), label: {
                    WindowView(article: article)
                    })
                               
            }
            .onAppear {

                api.searched = changedValue

                api.getPost { model in
                    articles = model.articles
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { value in
                if value.last != " " {
                    changedValue = value.replacingOccurrences(of: space, with: spaceChanger)
                }
                if value.isEmpty {
                    changedValue = "Apple"
                } else {
                    
                    api.searched = changedValue
                    api.getPost { model in
                        articles = model.articles
                    }
                }
            }
            
            .navigationTitle("News")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        articles = articles.shuffled()
                    } label: {
                        Label("Shuffle", systemImage: "shuffle")
                    }
                    
                        Button {
                            articles = articles.sorted {
                                (article1, article2) -> Bool in
                                return article1.title ?? "" < article2.title ?? ""
                            }
                        } label: {
                            Label("By Title", systemImage: "text.bubble")
                        }
                    

                    Menu {
                        Button {
                            articles = articles.sorted {
                                (article1, article2) -> Bool in
                                return article1.publishedAt ?? "" > article2.publishedAt ?? ""
                            }
                        } label: {
                            Label("From Now", systemImage: "arrow.down")
                        }

                        Button {
                            articles = articles.sorted {
                                (article1, article2) -> Bool in
                                return article1.publishedAt ?? "" < article2.publishedAt ?? ""
                            }
                        } label: {
                            Label("From Last", systemImage: "arrow.up")
                        }

                    } label: {
                        Label("By Date", systemImage: "calendar")
                    }

                    Menu {
                        Button {
                            articles = articles.sorted {
                                (article1, article2) -> Bool in
                                return article1.author ?? "" < article2.author ?? ""
                            }
                        } label: {
                            Label("Autors Name (A-Z)", systemImage: "arow.down")
                        }
                        
                        Button {
                            articles = articles.sorted {
                                (article1, article2) -> Bool in
                                return article1.author ?? "" > article2.author ?? ""
                            }
                        } label: {
                            Label("Autors Name (Z-A)", systemImage: "arow.up")
                        }
                        
                        Button {
                            alertSearching(title: "Searching", message: "Enter author name", hintText: "Steve Dent", primaryTitle: "Search", secondaryTitle: "Cancel") { text in
                                authorName = text
                                print(authorName)
                                articles = articles.filter({ (article) -> Bool in
                                    return article.author == searchText
                                })
                            } secondaryAction: {
                                print("Cancelled")
                            }

                        } label: {
                            Label("Enter Name", systemImage: "placeholdertext.fill")
                        }


                    } label: {
                        Label("By Author", systemImage: "person")
                    }

                } label: {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
                }
                
            }
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

extension View {
    func alertSearching(title: String, message: String, hintText: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (String)->(), secondaryAction: @escaping ()->()){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = hintText
        }
        
        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))
        
        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
        }))
        
        rootController().present(alert, animated: true, completion: nil)
        
    }
    
    func rootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        
        return root
    }
}

