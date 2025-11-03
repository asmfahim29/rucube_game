import 'package:flutter/material.dart';

const kCanvasSize = Size(1080, 1920);
double get kCenterX => kCanvasSize.width / 2; // virtual world space
const kGravity = 2200.0;              // px/s^2 downward
const kBallRadius = 44.0;
const kHoopY = 520.0;                 // hoop center Y
const kHoopInnerWidth = 240.0;        // “score window” width
const kHoopThickness = 14.0;          // rim thickness for visuals
const kReleaseScale = 2.2;            // swipe → initial velocity scale
const kFriction = 0.998;              // tiny damping per tick
const kMissFloorY = 1800.0;           // below = miss

// Difficulty
const kMoveStartScore = 10;
const kSpeedStep = 120.0;             // hoop speed increment per tier
const kBaseHoopSpeed = 0.0;

// Colors / style
const kBgColor = Color(0xFFF7F7FB);
const kHoopColor = Colors.red;
const kBallColor = Colors.orange;
const kTextColor = Color(0xFF222222);