import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallpaper_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class WallpaperRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WallpaperRepository() {
    seedWallpapersIfEmpty();
  }

  /// Returns fallback prebuilt list if Firestore is empty or offline
  List<WallpaperModel> getPrebuiltList() {
    final now = DateTime.now();
    return [
      WallpaperModel(
        id: 'prebuilt_01',
        name: 'Cosmic Anime Nebula',
        description: 'Cosmic Anime Nebula HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_01.png',
        thumbnailUrl: 'assets/images/prebuilt_01.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 1085,
        likes: 435,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_02',
        name: 'Cyberpunk Drift Legend',
        description: 'Cyberpunk Drift Legend HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_02.png',
        thumbnailUrl: 'assets/images/prebuilt_02.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 1170,
        likes: 470,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_03',
        name: 'Fiery Warrior Spirit',
        description: 'Fiery Warrior Spirit HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_03.png',
        thumbnailUrl: 'assets/images/prebuilt_03.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 1255,
        likes: 505,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_04',
        name: 'Japan Sunset Street',
        description: 'Japan Sunset Street HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_04.png',
        thumbnailUrl: 'assets/images/prebuilt_04.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 1340,
        likes: 540,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_05',
        name: 'Minimalist Anime Peak',
        description: 'Minimalist Anime Peak HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_05.png',
        thumbnailUrl: 'assets/images/prebuilt_05.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 1425,
        likes: 575,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_06',
        name: 'Neon Cyber Temple',
        description: 'Neon Cyber Temple HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_06.png',
        thumbnailUrl: 'assets/images/prebuilt_06.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 1510,
        likes: 610,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_07',
        name: 'Neon Samurai Horizon',
        description: 'Neon Samurai Horizon HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_07.png',
        thumbnailUrl: 'assets/images/prebuilt_07.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 1595,
        likes: 645,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_08',
        name: 'Cybernetic Geisha Glow',
        description: 'Cybernetic Geisha Glow HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_08.png',
        thumbnailUrl: 'assets/images/prebuilt_08.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 1680,
        likes: 680,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_09',
        name: 'Dark Phoenix Aura',
        description: 'Dark Phoenix Aura HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_09.png',
        thumbnailUrl: 'assets/images/prebuilt_09.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 1765,
        likes: 715,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_10',
        name: 'Galactic Drift Realm',
        description: 'Galactic Drift Realm HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_10.png',
        thumbnailUrl: 'assets/images/prebuilt_10.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 1850,
        likes: 750,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_11',
        name: 'Mystic Dragon Peak',
        description: 'Mystic Dragon Peak HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_11.png',
        thumbnailUrl: 'assets/images/prebuilt_11.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 1935,
        likes: 785,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_12',
        name: 'Ethereal Sunset Falls',
        description: 'Ethereal Sunset Falls HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_12.png',
        thumbnailUrl: 'assets/images/prebuilt_12.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 2020,
        likes: 820,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_13',
        name: 'Vaporwave Hypercar',
        description: 'Vaporwave Hypercar HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_13.png',
        thumbnailUrl: 'assets/images/prebuilt_13.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 2105,
        likes: 855,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_14',
        name: 'Cosmic Celestial Void',
        description: 'Cosmic Celestial Void HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_14.png',
        thumbnailUrl: 'assets/images/prebuilt_14.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 2190,
        likes: 890,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_15',
        name: 'Quantum Matrix Core',
        description: 'Quantum Matrix Core HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_15.png',
        thumbnailUrl: 'assets/images/prebuilt_15.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 2275,
        likes: 925,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_16',
        name: 'Shadow Ninja Stance',
        description: 'Shadow Ninja Stance HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_16.png',
        thumbnailUrl: 'assets/images/prebuilt_16.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 2360,
        likes: 960,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_17',
        name: 'Aura Crystal Cavern',
        description: 'Aura Crystal Cavern HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_17.png',
        thumbnailUrl: 'assets/images/prebuilt_17.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 2445,
        likes: 995,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_18',
        name: 'Orbital Sunset Station',
        description: 'Orbital Sunset Station HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_18.png',
        thumbnailUrl: 'assets/images/prebuilt_18.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 2530,
        likes: 1030,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_19',
        name: 'Hyperdrive Neon Speed',
        description: 'Hyperdrive Neon Speed HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_19.png',
        thumbnailUrl: 'assets/images/prebuilt_19.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 2615,
        likes: 1065,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_20',
        name: 'Luminous Sakura Shrine',
        description: 'Luminous Sakura Shrine HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_20.png',
        thumbnailUrl: 'assets/images/prebuilt_20.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 2700,
        likes: 1100,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_21',
        name: 'Supernova Ignition',
        description: 'Supernova Ignition HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_21.png',
        thumbnailUrl: 'assets/images/prebuilt_21.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 2785,
        likes: 1135,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_22',
        name: 'Dark Knight Citadel',
        description: 'Dark Knight Citadel HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_22.png',
        thumbnailUrl: 'assets/images/prebuilt_22.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 2870,
        likes: 1170,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_23',
        name: 'Retro Synth Wave Road',
        description: 'Retro Synth Wave Road HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_23.png',
        thumbnailUrl: 'assets/images/prebuilt_23.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 2955,
        likes: 1205,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_24',
        name: 'Zen Lotus Mirror Lake',
        description: 'Zen Lotus Mirror Lake HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_24.png',
        thumbnailUrl: 'assets/images/prebuilt_24.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 3040,
        likes: 1240,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_25',
        name: 'Cyber Phantom Protocol',
        description: 'Cyber Phantom Protocol HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_25.png',
        thumbnailUrl: 'assets/images/prebuilt_25.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 3125,
        likes: 1275,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_26',
        name: 'Interstellar Stellar Drift',
        description: 'Interstellar Stellar Drift HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_26.png',
        thumbnailUrl: 'assets/images/prebuilt_26.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 3210,
        likes: 1310,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_27',
        name: 'Blood Moon Awakening',
        description: 'Blood Moon Awakening HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_27.png',
        thumbnailUrl: 'assets/images/prebuilt_27.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 3295,
        likes: 1345,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_28',
        name: 'Minimalist Solar Eclipse',
        description: 'Minimalist Solar Eclipse HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_28.png',
        thumbnailUrl: 'assets/images/prebuilt_28.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 3380,
        likes: 1380,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_29',
        name: 'Neon Tokyo Rain Alley',
        description: 'Neon Tokyo Rain Alley HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_29.png',
        thumbnailUrl: 'assets/images/prebuilt_29.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 3465,
        likes: 1415,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_30',
        name: 'Vortex Dimension Rift',
        description: 'Vortex Dimension Rift HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_30.png',
        thumbnailUrl: 'assets/images/prebuilt_30.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 3550,
        likes: 1450,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_31',
        name: 'Spectral Dragon Flame',
        description: 'Spectral Dragon Flame HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_satoshi',
        creatorName: 'Satoshi',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'satoshi'],
        imageUrl: 'assets/images/prebuilt_31.png',
        thumbnailUrl: 'assets/images/prebuilt_31.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 3635,
        likes: 1485,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_32',
        name: 'Titan Mech Vanguard',
        description: 'Titan Mech Vanguard HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_otakuart',
        creatorName: 'OtakuArt',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'otakuart'],
        imageUrl: 'assets/images/prebuilt_32.png',
        thumbnailUrl: 'assets/images/prebuilt_32.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 3720,
        likes: 1520,
        rating: 4.7,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_33',
        name: 'Deep Space Galaxy Spiral',
        description: 'Deep Space Galaxy Spiral HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_matrix',
        creatorName: 'Matrix',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'matrix'],
        imageUrl: 'assets/images/prebuilt_33.png',
        thumbnailUrl: 'assets/images/prebuilt_33.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 2,
        status: 'approved',
        downloads: 3805,
        likes: 1555,
        rating: 4.8,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_34',
        name: 'Cyber Skyline Neon Heights',
        description: 'Cyber Skyline Neon Heights HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_luna',
        creatorName: 'Luna',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'luna'],
        imageUrl: 'assets/images/prebuilt_34.png',
        thumbnailUrl: 'assets/images/prebuilt_34.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 49,
        status: 'approved',
        downloads: 3890,
        likes: 1590,
        rating: 4.9,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_35',
        name: 'Storm Over Ruined City',
        description: 'Storm Over Ruined City HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_speedy',
        creatorName: 'Speedy',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'speedy'],
        imageUrl: 'assets/images/prebuilt_35.png',
        thumbnailUrl: 'assets/images/prebuilt_35.png',
        resolution: '8K UHD',
        isPremium: false,
        price: 0,
        status: 'approved',
        downloads: 3975,
        likes: 1625,
        rating: 4.5,
        createdAt: now,
        updatedAt: now,
      ),
      WallpaperModel(
        id: 'prebuilt_36',
        name: 'Uchiha Madara Shadow',
        description: 'Uchiha Madara Shadow HD Anime Wallpaper artwork for home and lock screens.',
        creatorId: 'creator_zendesign',
        creatorName: 'ZenDesign',
        category: 'anime',
        tags: ['anime', 'wallpaper', 'hd', '4k', 'zendesign'],
        imageUrl: 'assets/images/prebuilt_36.png',
        thumbnailUrl: 'assets/images/prebuilt_36.png',
        resolution: '8K UHD',
        isPremium: true,
        price: 2,
        status: 'approved',
        downloads: 4060,
        likes: 1660,
        rating: 4.6,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Seeds Firestore with all 36 prebuilt wallpapers
  Future<void> seedWallpapersIfEmpty() async {
    try {
      final prebuilt = getPrebuiltList();
      for (final item in prebuilt) {
        await _firestore.collection('wallpapers').doc(item.id).set(item.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      // Fail silently if offline
    }
  }

  Future<List<WallpaperModel>> getTrendingWallpapers({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('wallpapers')
          .where('status', isEqualTo: 'approved')
          .orderBy('downloads', descending: true)
          .limit(limit)
          .get();

      final docs = snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();
      if (docs.isEmpty) {
        final fallback = getPrebuiltList();
        fallback.sort((a, b) => b.downloads.compareTo(a.downloads));
        return fallback.take(limit).toList();
      }
      return docs;
    } catch (e) {
      final fallback = getPrebuiltList();
      fallback.sort((a, b) => b.downloads.compareTo(a.downloads));
      return fallback.take(limit).toList();
    }
  }

  /// Real query filtering against Firestore collection with prebuilt fallback
  Future<List<WallpaperModel>> getWallpapers({String? category, String? query, int limit = 50}) async {
    try {
      Query firestoreQuery = _firestore.collection('wallpapers').where('status', isEqualTo: 'approved');

      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.toLowerCase());
      }

      final snapshot = await firestoreQuery.limit(limit).get();
      var list = snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList();

      if (list.isEmpty) {
        list = getPrebuiltList();
        if (category != null && category.isNotEmpty) {
          list = list.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
        }
      }

      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((w) => w.name.toLowerCase().contains(q) || w.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }

      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      return list;
    } catch (e) {
      var list = getPrebuiltList();
      if (category != null && category.isNotEmpty) {
        list = list.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((w) => w.name.toLowerCase().contains(q) || w.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      return list;
    }
  }

  Future<WallpaperModel?> getWallpaperById(String id) async {
    try {
      final doc = await _firestore.collection('wallpapers').doc(id).get();
      if (doc.exists) {
        return WallpaperModel.fromFirestore(doc);
      }
      final prebuilt = getPrebuiltList();
      return prebuilt.firstWhere((w) => w.id == id, orElse: () => prebuilt.first);
    } catch (e) {
      final prebuilt = getPrebuiltList();
      return prebuilt.firstWhere((w) => w.id == id, orElse: () => prebuilt.first);
    }
  }

  Future<void> createWallpaper(WallpaperModel wallpaper) async {
    await _firestore.collection('wallpapers').doc(wallpaper.id).set(wallpaper.toFirestore());
  }

  Future<void> incrementDownloads(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> incrementLikes(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'likes': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> decrementLikes(String id) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (_) {}
  }

  Future<void> updateRating(String id, double newRating, int newRatingCount) async {
    try {
      await _firestore.collection('wallpapers').doc(id).update({
        'rating': newRating,
        'ratingCount': newRatingCount,
      });
    } catch (_) {}
  }
}
