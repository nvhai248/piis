import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res.user;
    } catch (error) {
      print('Error signing in with email: $error');
      rethrow;
    }
  }

  Future<User?> signUpWithEmail(String email, String password, String fullName) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return res.user;
    } catch (error) {
      print('Error signing up with email: $error');
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Check if already signed in to Google
      GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        // Start the Google sign-in process
        currentUser = await _googleSignIn.signIn();
      }
      
      if (currentUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Get auth details from Google
      final GoogleSignInAuthentication googleAuth = await currentUser.authentication;
      
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // Sign in to Supabase with Google credentials
      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (res.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Update user metadata if needed
      if (res.user!.userMetadata?['full_name'] == null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': currentUser.displayName ?? 'User',
              'avatar_url': currentUser.photoUrl,
            },
          ),
        );
      }

      return res.user;
    } catch (error) {
      print('Error signing in with Google: $error');
      // Sign out from Google if there was an error
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
      }
      rethrow;
    }
  }

  Future<UserProfile> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (error) {
      // If profile doesn't exist, create one from user data
      return UserProfile.fromUser(user);
    }
  }

  Future<UserProfile> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? avatarFile,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      String? avatarUrl;
      if (avatarFile != null) {
        final fileExt = avatarFile.path.split('.').last;
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${user.id}/$fileName';

        // Upload avatar
        await supabase.storage
            .from('avatars')
            .upload(
              filePath,
              avatarFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // Get public URL
        avatarUrl = supabase.storage
            .from('avatars')
            .getPublicUrl(filePath);
      }

      // Update user metadata
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (phoneNumber != null) 'phone_number': phoneNumber,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      // Update or insert profile in profiles table
      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName ?? user.userMetadata?['full_name'],
        'phone_number': phoneNumber ?? user.userMetadata?['phone_number'],
        'avatar_url': avatarUrl ?? user.userMetadata?['avatar_url'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('profiles')
          .upsert(profileData);

      return getCurrentProfile();
    } catch (error) {
      print('Error updating profile: $error');
      rethrow;
    }
  }

  Future<void> deleteAvatar() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current avatar URL
      final currentAvatarUrl = user.userMetadata?['avatar_url'] as String?;
      if (currentAvatarUrl == null) return;

      // Extract file path from URL
      final uri = Uri.parse(currentAvatarUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 2) return;

      // Delete from storage
      await supabase.storage
          .from('avatars')
          .remove([pathSegments.last]);

      // Update user metadata
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'avatar_url': null,
          },
        ),
      );

      // Update profile
      await supabase
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', user.id);
    } catch (error) {
      print('Error deleting avatar: $error');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChange => supabase.auth.onAuthStateChange;
} 