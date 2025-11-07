import 'package:greentalkies/models/fertilzer_model.dart';

class FertilizerService {
  Future<List<Fertilizer>> fetchFertilizers() async {
    // TODO: Replace with your real API call using http.get()
    // Example endpoint: http://<server-ip>:5000/api/fertilizers

    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    final dummyData = [
      {
        'id': '1',
        'name': 'BioGrow Compost',
        'description': 'Enriched with beneficial microbes.',
        'price': 249,
        'imageUrl': 'assets/biogrow.webp'
      },
      {
        'id': '2',
        'name': 'Neem Cake',
        'description': 'Natural pest repellent for all plants.',
        'price': 199,
        'imageUrl': 'assets/neem_cake.jpg'
      },
      {
        'id': '3',
        'name': 'VermiCompost Mix',
        'description': 'Improves soil structure & fertility.',
        'price': 299,
        'imageUrl': 'assets/vermicompost.jpg'
      },
      {
        'id': '4',
        'name': 'Seaweed Extract',
        'description': 'Boosts plant growth & root health.',
        'price': 349,
        'imageUrl': 'assets/seaweed_extract.png'
      },
      {
        'id': '5',
        'name': 'Bone Meal',
        'description': 'Excellent source of phosphorus.',
        'price': 179,
        'imageUrl': 'assets/boneMeal.jpg'
      },
      {
        'id': '6',
        'name': 'Mustard Cake Powder',
        'description': 'Promotes flowering & fruiting.',
        'price': 159,
        'imageUrl': 'assets/mustard_cake.jpg'
      },
      {
        'id': '7',
        'name': 'Organic NPK Blend',
        'description': 'Balanced nutrients for all greens.',
        'price': 379,
        'imageUrl': 'assets/npk_blend.webp'
      },
      {
        'id': '8',
        'name': 'Coco Peat Fertilizer',
        'description': 'Improves aeration & moisture retention.',
        'price': 199,
        'imageUrl': 'assets/coco_peat.jpg'
      },
      {
        'id': '9',
        'name': 'Fish Amino Acid',
        'description': 'Natural nitrogen source for plants.',
        'price': 269,
        'imageUrl': 'assets/fish_amino_acid.jpg'
      },
      {
        'id': '10',
        'name': 'Compost Tea',
        'description': 'Liquid fertilizer for instant results.',
        'price': 229,
        'imageUrl': 'assets/compost_tea.jpg'
      },
    ];

    return dummyData.map((e) => Fertilizer.fromJson(e)).toList();
  }
}
