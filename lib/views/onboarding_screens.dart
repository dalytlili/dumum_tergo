import 'package:flutter/material.dart';
import 'package:dumum_tergo/views/welcome_screen.dart';
import 'package:dumum_tergo/constants/colors.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  _OnboardingScreensState createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Découvrez le Camping en Tunisie',
      description:
          'En Tunisie, la culture du Camping-cars est quasiment inexistante par rapport à d\'autres pays occidentaux où ce mode de voyage est plus courant..',
      imagePath: 'assets/images/image1.png',
    ),
    OnboardingPageData(
      title: 'Dumum Tergo : Une Nouvelle Perspective',
      description:
          'D\'ou l\'importance de Dumum Tergo !\nNous vous offrons des expériences immersives combinant exploration des paysages et découvertes culturelles.',
      imagePath: 'assets/images/image1.png',
    ),
    OnboardingPageData(
      title: 'Voyagez Autrement',
      description:
          'Dumum Tergo vous invite à repenser votre façon de voyager.\nDécouvrez la liberté et l\'authenticité du voyage en camping-car.',
      imagePath: 'assets/images/image3.png',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Welcome Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate back to splash screen or previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                onNextPressed: _nextPage,
                onBackPressed: _previousPage,
                isLastPage: index == _pages.length - 1,
                isFirstPage: index == 0,
              );
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;
  final bool isLastPage;
  final bool isFirstPage;

  const _OnboardingPage({
    required this.data,
    required this.onNextPressed,
    required this.onBackPressed,
    required this.isLastPage,
    required this.isFirstPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              if (!isFirstPage)
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: onBackPressed,
                  ),
                ),

              // Image
              Expanded(
                flex: 3,
                child: Image.asset(
                  data.imagePath,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                data.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Next/Get Started Button
              ElevatedButton(
                onPressed: onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isLastPage ? 'Commencer' : 'Suivant',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
