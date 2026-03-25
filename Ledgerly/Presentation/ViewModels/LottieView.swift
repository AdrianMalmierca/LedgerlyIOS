import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UIView {
        //create a container view to hold the animation, with initial size zero
        let view = UIView(frame: .zero)

        //create the Lottie animation view with the name
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit //scale the animation to fit the container view
        animationView.loopMode = .playOnce //is played only once
        animationView.play() //start the animation

        animationView.translatesAutoresizingMaskIntoConstraints = false //not generate constraints
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
