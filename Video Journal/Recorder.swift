import AVFoundation

enum ApertureError: Error {
  case invalidAudioDevice
  case couldNotAddScreen
  case couldNotAddMic
  case couldNotAddOutput
}

final class Recorder: NSObject {
  private let destination: URL
  private let session: AVCaptureSession
  private let output: AVCaptureMovieFileOutput

  var onStart: (() -> Void)?
  var onFinish: (() -> Void)?
  var onError: ((Error) -> Void)?
  var onPause: (() -> Void)?
  var onResume: (() -> Void)?

  var isRecording: Bool {
    return output.isRecording
  }

  var isPaused: Bool {
    return output.isRecordingPaused
  }

  init(destination: URL, fps: Int, cropRect: CGRect?, showCursor: Bool, highlightClicks: Bool, displayId: CGDirectDisplayID = CGMainDisplayID(), audioDevice: AVCaptureDevice? = .default(for: .audio)) throws {
    self.destination = destination
    session = AVCaptureSession()

    let input = AVCaptureScreenInput(displayID: displayId)

    input.minFrameDuration = CMTimeMake(1, Int32(fps))

    if let cropRect = cropRect {
      input.cropRect = cropRect
    }

    input.capturesCursor = showCursor
    input.capturesMouseClicks = highlightClicks

    output = AVCaptureMovieFileOutput()

    // Needed because otherwise there is no audio on videos longer than 10 seconds
    // http://stackoverflow.com/a/26769529/64949
    output.movieFragmentInterval = kCMTimeInvalid

    if let audioDevice = audioDevice {
      if !audioDevice.hasMediaType(.audio) {
        throw ApertureError.invalidAudioDevice
      }

      let audioInput = try AVCaptureDeviceInput(device: audioDevice)

      if session.canAddInput(audioInput) {
        session.addInput(audioInput)
      } else {
        throw ApertureError.couldNotAddMic
      }
    }

    if session.canAddInput(input) {
      session.addInput(input)
    } else {
      throw ApertureError.couldNotAddScreen
    }

    if session.canAddOutput(output) {
      session.addOutput(output)
    } else {
      throw ApertureError.couldNotAddOutput
    }

    super.init()
  }

  func start() {
    session.startRunning()
    output.startRecording(to: destination, recordingDelegate: self)
  }

  func stop() {
    output.stopRecording()
    session.stopRunning()
  }

  func pause() {
    output.pauseRecording()
  }

  func resume() {
    output.resumeRecording()
  }
}

extension Recorder: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    onStart?()
  }

  func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    let FINISHED_RECORDING_ERROR_CODE = -11806

    if let error = error, error._code != FINISHED_RECORDING_ERROR_CODE {
      onError?(error)
    } else {
      onFinish?()
    }
  }

  func fileOutput(_ output: AVCaptureFileOutput, didPauseRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    onPause?()
  }

  func fileOutput(_ output: AVCaptureFileOutput, didResumeRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    onResume?()
  }

  func fileOutputShouldProvideSampleAccurateRecordingStart(_ output: AVCaptureFileOutput) -> Bool {
    return true
  }
}
