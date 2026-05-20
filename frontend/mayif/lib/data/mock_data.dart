class Destination {
  final String title;
  final String image;
  final String category;
  final double rating;

  Destination({required this.title, required this.image, required this.category, required this.rating});
}

class Activity {
  final String title;
  final String emoji;
  final String duration;
  final String price;

  Activity({required this.title, required this.emoji, required this.duration, required this.price});
}

final List<Destination> mockDestinations = [
  Destination(
    title: 'Plage de Lomé',
    image: 'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=600',
    category: 'Plage',
    rating: 4.8,
  ),
  Destination(
    title: 'Mont Agou',
    image: 'https://images.pexels.com/photos/15187092/pexels-photo-15187092.jpeg?auto=compress&cs=tinysrgb&w=600',
    category: 'Montagne',
    rating: 4.9,
  ),
  Destination(
    title: 'Marché d\'Atakpamé',
    image: 'https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=600',
    category: 'Culture',
    rating: 4.7,
  ),
];

final List<Activity> mockActivities = [
  Activity(title: 'Safari Nature', emoji: '🦁', duration: '4h', price: '15.000 F'),
  Activity(title: 'Surf Atlantique', emoji: '🏄‍♂️', duration: '2h', price: '10.000 F'),
  Activity(title: 'Rando Kpalimé', emoji: '🥾', duration: '6h', price: '12.000 F'),
  Activity(title: 'Visite Musées', emoji: '🏛️', duration: '3h', price: '5.000 F'),
];
