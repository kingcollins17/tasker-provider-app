import 'package:go_router/go_router.dart';
import 'presentation/kyc_onboarding_screen.dart';
import 'presentation/document_submission_screen.dart';

/// Route definitions for KYC feature screens.
class KycRoutes {
  KycRoutes._();

  static const String kycOnboardingRoute = 'kyc-onboarding';
  static const String documentSubmissionRoute = 'document-submission';

  static final routes = <GoRoute>[
    GoRoute(
      path: '/kyc-onboarding',
      name: kycOnboardingRoute,
      builder: (context, state) => const KycOnboardingScreen(),
    ),
    GoRoute(
      path: '/document-submission',
      name: documentSubmissionRoute,
      builder: (context, state) => const DocumentSubmissionScreen(),
    ),
  ];
}
