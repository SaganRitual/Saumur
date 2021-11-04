// Many thanks to https://stackoverflow.com/users/3820660/hello-world
// https://stackoverflow.com/a/63389253/1610473

import SwiftUI

struct VisibilityControlView: View {
    @Binding var checked: Bool

    let label: String

    var body: some View {
        HStack {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(NSColor.systemBlue) : Color.secondary)
                .onTapGesture { self.checked.toggle() }
                .frame(width: 30, alignment: .leading)

            Text(label).font(.body)
        }
    }
}

struct VisibilityControlView_Previews: PreviewProvider {
    struct CheckBoxViewHolder: View {
        @State var checked = false

        var body: some View {
            VisibilityControlView(checked: $checked, label: "Hogwarts")
        }
    }

    static var previews: some View {
        CheckBoxViewHolder()
    }
}
