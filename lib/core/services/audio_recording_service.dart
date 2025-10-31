import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  /// Check if recording permission is granted
  Future<bool> hasPermission() async {
    try {
      if (kIsWeb) {
        // For web, we need to check microphone permission differently
        return await _recorder.hasPermission();
      } else {
        // For mobile/desktop platforms
        final status = await Permission.microphone.status;
        return status.isGranted;
      }
    } catch (e) {
      //debugPrint('Error checking recording permission: $e');
      return false;
    }
  }

  /// Request recording permission
  Future<bool> requestPermission() async {
    try {
      if (kIsWeb) {
        // For web, use the recorder's permission method
        return await _recorder.hasPermission();
      } else {
        // For mobile/desktop platforms
        final status = await Permission.microphone.request();
        return status.isGranted;
      }
    } catch (e) {
      //debugPrint('Error requesting recording permission: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      // Check permission first
      bool hasPermission = await this.hasPermission();
      if (!hasPermission) {
        hasPermission = await requestPermission();
        if (!hasPermission) {
          //debugPrint('Recording permission denied');
          return false;
        }
      }

      // Generate unique file path
      final path = await _generateRecordingPath();
      if (path == null) {
        //debugPrint('Failed to generate recording path');
        return false;
      }

      // Configure recording settings based on platform
      RecordConfig config;
      if (kIsWeb) {
        config = const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );
      } else if (Platform.isIOS) {
        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );
      } else if (Platform.isAndroid) {
        // Android specific configuration with minimal settings for maximum compatibility
        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );
      } else {
        // Other platforms
        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );
      }

      // Start recording
      //debugPrint('Attempting to start recording with path: $path');
      //debugPrint('Recording config: encoder=${config.encoder}, bitRate=${config.bitRate}, sampleRate=${config.sampleRate}');
      
      await _recorder.start(config, path: path);
      
      // Wait a brief moment for recording to initialize
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verify recording started
      final isRecording = await _recorder.isRecording();
      if (!isRecording) {
        //debugPrint('Failed to start recording - recorder reports not recording');
        return false;
      }
      
      _currentRecordingPath = path;
      _recordingStartTime = DateTime.now();
      
      //debugPrint('Successfully started recording to: $path');
      
      // Verify file exists (for non-web platforms)
      if (!kIsWeb) {
        final file = File(path);
        if (await file.exists()) {
          //debugPrint('Recording file exists: $path');
        } else {
          //debugPrint('Warning: Recording file does not exist immediately after starting: $path');
        }
      }
      
      return true;
    } catch (e) {
      //debugPrint('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording and return the file path and duration
  Future<AudioRecordingResult?> stopRecording() async {
    try {
      if (_currentRecordingPath == null || _recordingStartTime == null) {
        //debugPrint('No active recording to stop');
        return null;
      }

      // Stop recording
      await _recorder.stop();
      
      // Calculate duration
      final duration = DateTime.now().difference(_recordingStartTime!);
      
      final result = AudioRecordingResult(
        path: _currentRecordingPath!,
        duration: duration.inSeconds,
      );
      
      // Reset recording state
      _currentRecordingPath = null;
      _recordingStartTime = null;
      
      // Verify the file exists and has content
      if (!kIsWeb) {
        final file = File(result.path);
        if (await file.exists()) {
          final fileSize = await file.length();
          //debugPrint('Stopped recording: ${result.path}, duration: ${result.duration}s, size: $fileSize bytes');
          if (fileSize == 0) {
            //debugPrint('Warning: Audio file is empty');
          }
        } else {
          //debugPrint('Warning: Audio file does not exist after recording');
        }
      } else {
        //debugPrint('Stopped recording (Web): ${result.path}, duration: ${result.duration}s');
      }
      
      return result;
    } catch (e) {
      //debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      //debugPrint('Error checking recording status: $e');
      return false;
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (await isRecording()) {
        await _recorder.stop();
        
        // Delete the recording file if it exists
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
            //debugPrint('Deleted cancelled recording: $_currentRecordingPath');
          }
        }
        
        // Reset recording state
        _currentRecordingPath = null;
        _recordingStartTime = null;
      }
    } catch (e) {
      //debugPrint('Error cancelling recording: $e');
    }
  }

  /// Generate a unique file path for recording
  Future<String?> _generateRecordingPath() async {
    try {
      Directory directory;
      String extension;
      
      if (kIsWeb) {
        // For web, use a simple filename (browser will handle storage)
        extension = 'wav';
        return 'audio_${DateTime.now().millisecondsSinceEpoch}.$extension';
      } else {
        // For mobile/desktop, use appropriate directory based on platform
        if (Platform.isAndroid) {
          // Try external storage first, fall back to application support
          try {
            final Directory? externalDir = await getExternalStorageDirectory();
            directory = externalDir ?? await getApplicationSupportDirectory();
          } catch (e) {
            //debugPrint('Failed to get external storage, using app support: $e');
            directory = await getApplicationSupportDirectory();
          }
          extension = 'aac';
        } else if (Platform.isIOS) {
          // Use documents directory for iOS
          directory = await getApplicationDocumentsDirectory();
          extension = 'm4a';
        } else {
          // For other platforms, use documents directory
          directory = await getApplicationDocumentsDirectory();
          extension = 'aac';
        }
        
        // Create audio directory if it doesn't exist
        final audioDir = Directory('${directory.path}/audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
          //debugPrint('Created audio directory: ${audioDir.path}');
        }
        
        final filePath = '${audioDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.$extension';
        //debugPrint('Generated recording path: $filePath');
        return filePath;
      }
    } catch (e) {
      //debugPrint('Error generating recording path: $e');
      return null;
    }
  }

  /// Dispose of the recorder
  void dispose() {
    _recorder.dispose();
  }
}

/// Result of an audio recording
class AudioRecordingResult {
  final String path;
  final int duration; // in seconds

  const AudioRecordingResult({
    required this.path,
    required this.duration,
  });
}