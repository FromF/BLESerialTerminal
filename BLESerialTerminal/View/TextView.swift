//
//  TextView.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UITextViewDelegate {
        private var textView: TextView

        init(_ textView: TextView) {
            self.textView = textView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            self.textView.text = textView.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
        
        //文末に移動
        let position = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: position, to: position)
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(text: .constant("Test"))
    }
}
