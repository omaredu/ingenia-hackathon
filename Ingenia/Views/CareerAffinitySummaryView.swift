import SwiftUI

struct CareerAffinitySummaryView: View {
    let careerAffinity: STEMAffinity
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the sheet

    private var totalAffinity: Int {
        careerAffinity.biotechnology + careerAffinity.robotics +
        careerAffinity.softwareEngineering + careerAffinity.dataScience +
        careerAffinity.environmentalEngineering
    }

    // Updated to Spanish names and keeping English keys for STEMAffinity struct
    private var affinityData: [(name: String, value: Int, color: Color)] {
        [
            ("Biotecnología", careerAffinity.biotechnology, .blue),
            ("Robótica", careerAffinity.robotics, .green),
            ("Ing. de Software", careerAffinity.softwareEngineering, .orange),
            ("Ciencia de Datos", careerAffinity.dataScience, .purple),
            ("Ing. Ambiental", careerAffinity.environmentalEngineering, .red)
        ].filter { $0.value > 0 } // Filter out careers with 0 affinity
    }

    var body: some View {
        VStack {
            Spacer()
            Image("Ingenia white")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .opacity(0.5)
            Spacer() // Add spacer at the top to push content down
            
            Text("Resumen de Afinidad Profesional")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .multilineTextAlignment(.center)

            Spacer() // Add spacer to help center the chart

            ZStack {
                if totalAffinity > 0 {
                    DonutChartView(data: affinityData, totalValue: CGFloat(totalAffinity))
                        .frame(width: 220, height: 220)
                } else {
                    Text("No hay datos de afinidad para mostrar.")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .frame(width: 250, height: 250)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical) // Add vertical padding to the chart container

            VStack(alignment: .leading, spacing: 8) {
                ForEach(affinityData, id: \.name) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 15, height: 15)
                        Text("\(item.name): \(item.value)")
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal)

            Spacer() // Add spacer to push content up from bottom
            
            Text("Basado en tus interacciones a lo largo de esta historia, hemos descubierto que eres una persona muy capaz y con un gran potencial para destacar en el campo STEM que elijas. ¡Sigue explorando y aprendiendo!")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)

            Button(action: {
                dismiss() // Dismiss the sheet
            }) {
                Text("Cerrar")
                    .font(.body)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct DonutSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    let clockwise: Bool
    let holeRadiusRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let holeRadius = radius * holeRadiusRatio
        var path = Path()

        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.addArc(center: center, radius: holeRadius, startAngle: endAngle, endAngle: startAngle, clockwise: !clockwise)
        path.closeSubpath()
        return path
    }
}

struct DonutChartView: View {
    let data: [(name: String, value: Int, color: Color)]
    let totalValue: CGFloat
    let holeRadiusRatio: CGFloat = 0.8

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let holeRadius = radius * holeRadiusRatio

                Circle()
                    .fill(Color(UIColor.systemBackground)) // Adapts to light/dark mode
                    .frame(width: holeRadius * 2, height: holeRadius * 2)

                ForEach(0..<data.count, id: \.self) { i in
                    let segment = data[i]
                    let startAngle = angle(for: data.prefix(i).reduce(0) { $0 + $1.value })
                    let endAngle = angle(for: data.prefix(i+1).reduce(0) { $0 + $1.value })

                    DonutSegment(
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false,
                        holeRadiusRatio: holeRadiusRatio
                    )
                    .fill(segment.color)
                }
            }
        }
    }

    private func angle(for value: Int) -> Angle {
        .degrees(Double(value) / Double(totalValue) * 360 - 90) // -90 to start from top
    }
}

struct CareerAffinitySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        CareerAffinitySummaryView(
            careerAffinity: STEMAffinity(
                biotechnology: 75,
                robotics: 90,
                softwareEngineering: 60,
                dataScience: 85,
                environmentalEngineering: 70
            )
        )
        .previewDisplayName("Spanish - All Data")
        
        CareerAffinitySummaryView(
            careerAffinity: STEMAffinity(
                biotechnology: 0,
                robotics: 0,
                softwareEngineering: 0,
                dataScience: 0,
                environmentalEngineering: 0
            )
        )
        .previewDisplayName("Spanish - No Data")
    }
} 
