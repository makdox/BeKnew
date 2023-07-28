
import SwiftUI

struct MoreView: View {
    @Environment(\.openURL) var openURL
    @State var article: Articles!
    
    var body: some View {
        ScrollView {
            VStack {
                ArticleHeaderView(article: article)
                
                Divider()
                
                Text(article.description ?? "Description")
                    .padding()
                
                Spacer()
                
                Button(action: {
                    openURL(URL(string: article.url ?? "")!)
                }) {
                    Text("Read More")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ArticleHeaderView: View {
    let article: Articles
    
    var body: some View {
        VStack {
            Text(article.title ?? "No Title")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            ArticleImageView(imageURL: article.urlToImage)
            
            AuthorAndPublishedDateView(article: article)
        }
    }
}

struct ArticleImageView: View {
    let imageURL: String?
    private let cornerRadius: CGFloat = 30
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
                .foregroundColor(.gray)
                .frame(height: 100)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .padding(.horizontal)
    }
}

struct AuthorAndPublishedDateView: View {
    let article: Articles
    
    var body: some View {
        HStack {
            Text(withFallbackText(article.author, fallback: "Author"))
            Image(systemName: "person.fill")
            
            Spacer()
            
            Text(article.publishedAt ?? "Date")
            Image(systemName: "timer")
        }
        .font(.subheadline)
        .foregroundColor(.gray)
        .padding(.horizontal)
    }
}
func withFallbackText(_ text: String?, fallback: String) -> String {
    return text ?? fallback
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
