//
//  Input2.swift
//  WeatherRecommend
//
//  Created by ohseungyeon on 2/13/24.
//
/*
[
  {
    "id": "1",
    "title": "민소매, 반팔, 반바지, 원피스",
    "completed": false
  },
  {
    "id": "2",
    "title": "반팔, 얇은 셔츠, 반바지, 면바지",
    "completed": true
  },
  {
    "id": "3",
    "title": "얇은 가디건, 긴팔, 면바지, 청바지",
    "completed": false
  },
  {
    "id": "4",
    "title": "얇은 니트, 맨투맨, 가디건, 청바지",
    "completed": false
  },
  {
    "id": "5",
    "title": "자켓, 가디건, 야상, 스타킹, 청바지, 면바지",
    "completed": true
  },
  {
    "id": "6",
    "title": "자켓, 트렌치코트, 야상, 니트, 청바지, 스타킹",
    "completed": true
  },
  {
    "id": "7",
    "title": "코트, 가죽자켓, 히트텍, 니트, 레깅스",
    "completed": true
  },
  {
    "id": "8",
    "title": "패딩, 두꺼운 코트, 목도리, 기모제품",
    "completed": true
  }
]
 */


import SwiftUI


struct Memo: Identifiable, Codable {
    var id = UUID()
    var content: String
}

class MemoStore: ObservableObject {
    @Published var memos: [Memo] {
        didSet {
            saveMemos()
        }
    }

    init() {
        self.memos = []
        loadMemos()
    }

    // 메모 저장 함수
    private func saveMemos() {
        do {
            let data = try JSONEncoder().encode(memos)
            UserDefaults.standard.set(data, forKey: "memos")
        } catch {
            print("메모 저장 실패: \(error.localizedDescription)")
        }
    }

    // 메모 불러오기 함수
    private func loadMemos() {
        if let data = UserDefaults.standard.data(forKey: "memos") {
            do {
                memos = try JSONDecoder().decode([Memo].self, from: data)
            } catch {
                print("메모 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }

    // 메모 삭제 함수
    func deleteMemo(_ memo: Memo) {
        memos.removeAll { $0.id == memo.id }
    }
}


struct Input2: View {
    @State var todos: [String] = []
    
    @State private var newMemo = ""
    @ObservedObject private var memoStore = MemoStore()

    
    var body: some View {
        
        VStack {
                    TextField("새로운 옷을 입력하세요", text: $newMemo)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        saveMemo()
                    }, label: {
                        ZStack {
                            Capsule()
                                .frame(width: 200, height: 40)
                                .foregroundColor(.orange)
                            Text("입력한 옷 추가")
                                .foregroundColor(.white)
                        }
                    })
            
            List {
                Section(header: Text("추천 옷")) {
                    ForEach(todos, id: \.self) { todo in
                        Text(todo)
                    }
                }
                .onAppear(){
                    requestData2()
                }
                

                Section(header: Text("내가 추가한 옷")) {
                    ForEach(memoStore.memos) { memo in
                        HStack {
                            Text(memo.content)
                            Spacer()
                            Button(action: {
                                // 삭제 버튼 눌렀을 때
                                memoStore.deleteMemo(memo)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            


                }
                .padding()
    }
    
    private func requestData2(){
        requestTodo2{todo, error in
            guard let todo = todo else{
                print("todo를 받아오는데 실패")
                return
            }
            todos.append(todo.title)
        }
    }
    
    func requestTodo2(completed: @escaping(Todo?, String?)->()){
        let endPoint = "https://65c22e19f7e6ea59682acdff.mockapi.io/weathers/2"

        guard let url = URL(string: endPoint) else {
            completed(nil, "잘못된 URL입니다.")
            return
        }
        
        let task: Void = URLSession.shared.dataTask(with: url){data, response, error in
            if let _ = error{
                completed(nil,"URL에 어떤 문제가 있습니다.")
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                completed(nil, "URL에서 정상적으로 응답을 받지 못했습니다.")
                return
            }
            guard let data = data else{
                completed(nil, "데이터를 받지 못했습니다.")
                return
            }
            
            do{
                let responseTodo = try JSONDecoder().decode(Todo.self, from: data)
                completed(responseTodo,nil)
            } catch{
                print(error)
            }
        }.resume()
    }
    
    private func saveMemo() {
        guard !newMemo.isEmpty else { return }
        memoStore.memos.append(Memo(content: newMemo))
        newMemo = ""
    }
}

#Preview {
    Input2()
}
