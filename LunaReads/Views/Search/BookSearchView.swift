import SwiftUI
import Combine

struct BookSearchView: View {
    @StateObject private var viewModel = BookSearchViewModel()
    @State private var showFilters = false
    
    
    
    // Чи є активні фільтри
    private var hasActiveFilters: Bool {
        !viewModel.filters.author.isEmpty ||
        !viewModel.filters.genre.isEmpty ||
        !viewModel.filters.year.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ОСНОВНИЙ КОНТЕНТ
                VStack(spacing: 20) {
                    // Тайтл-лейбл
                    VStack(spacing: 6) {
                        Text("LunaReads")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppColor.inkBlack)
                        
                        Text("Знаходь книжки під свій настрій ✨")
                            .font(.subheadline)
                            .foregroundColor(AppColor.inkBlack.opacity(0.7))
                    }.onTapGesture {
                        hideKeyboard()
                }
                    .padding(.top, 8)
                    
                  
                    
                    // Пошуковий рядок + кнопка пошук
                    HStack(spacing: 10) {
                        TextField("Назва книги…", text: $viewModel.query)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.paperWhite)
                                    .shadow(radius: 1, y: 1)
                            )
                            .tint(AppColor.blushPink)
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.search()
                                viewModel.suggestions = []
                            }
                            .onChange(of: viewModel.query) { newValue in
                                if viewModel.blockSuggestions {
                                    viewModel.blockSuggestions = false
                                    return
                                }
                                viewModel.queryChanged(newValue)
                            }
                        
                        Button {
                            viewModel.search()
                            viewModel.suggestions = []
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                               
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(AppColor.blushPink)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            showFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(
                                    hasActiveFilters ? AppColor.inkBlack : AppColor.blushPink
                                )
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(AppColor.paperWhite)
                                        .shadow(radius: 1, y: 1)
                                )
                        }
                    }.onTapGesture {
                        hideKeyboard()
                }
                    
                    // РЕЗУЛЬТАТИ
                    if viewModel.isLoading && viewModel.books.isEmpty {
                        Spacer()
                        ProgressView("Шукаю книжки…")
                            .padding()
                        Spacer()
                    } else if !viewModel.books.isEmpty {
                        BookResultsView(
                            books: viewModel.books,
                            isLoading: viewModel.isLoading,
                            loadMore: { book in
                                viewModel.loadMoreIfNeeded(currentItem: book)
                            }
                        )
                    } else {
                        VStack{  Spacer()
                            Text("Почни з пошуку книги 💫")
                                .foregroundColor(AppColor.inkBlack.opacity(0.7))
                            Spacer()}.onTapGesture {
                                hideKeyboard()
                        }
                    }
                }
                .background(
                    LinearGradient(
                        colors: [AppColor.paperWhite, AppColor.lavender.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                
                // ДРОПДАУН ПОВЕРХ
                if !viewModel.suggestions.isEmpty {
                    SearchSuggestionsView(
                        suggestions: viewModel.suggestions,
                        onSelect: { title in
                            viewModel.blockSuggestions = true
                            viewModel.query = title
                            viewModel.suggestions = []
                            viewModel.search()
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top,150) // відступ від верху до ЗОНІ ПІД ПОШУКОМ
                    .zIndex(1)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilters) {
                BookFiltersView(
                    filters: $viewModel.filters,
                    onApply: {
                        showFilters = false
                        viewModel.search()
                    },
                    onClear: {
                        viewModel.filters = BookFilterOptions()
                    }
                )
            }
        }
    }
    
}
func hideKeyboard() {
       let resign = #selector(UIResponder.resignFirstResponder)
       UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
   }
