import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class AudioWaveWidget extends StatefulWidget {
  final String path;

  const AudioWaveWidget({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  State<AudioWaveWidget> createState() => _AudioWaveWidgetState();
}

class _AudioWaveWidgetState extends State<AudioWaveWidget> {
  late PlayerController controller;
  int duration = 0;

  @override
  void initState() {
    super.initState();
    _preparePlayer();
  }

  void _preparePlayer() async {

    print('path ${widget.path}');
    controller = PlayerController(); // Initialise
    // Extract waveform data
    await controller.extractWaveformData(
      path: widget.path,
      noOfSamples: 100,
    );
    // Or directly extract from preparePlayer and initialise audio player
    // await controller.preparePlayer(
    //   path: widget.path,
    //   shouldExtractWaveform: true,
    //   noOfSamples: 100,
    //   volume: 1.0,
    // ); // Stop audio player
    await controller.setVolume(1.0); // Set volume level     // Seek audio
    duration = await controller.getDuration(DurationType.max);
    controller.onPlayerStateChanged.listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            if (controller.playerState.isPlaying) {
              await controller.pausePlayer();
              await controller.stopPlayer();
              setState(() {});
              return;
            }
            await controller.extractWaveformData(
              path: widget.path,
              noOfSamples: 100,
            );
            await controller.startPlayer(
                finishMode: FinishMode.loop); // Start audio player
            // await controller.pausePlayer();                                     // Pause audio player
            // await controller.stopPlayer();
            // controller.playerState.isPlaying
            //     ? await controller.pausePlayer()
            //     : await controller.startPlayer(
            //         finishMode: FinishMode.loop,
            //   forceRefresh: true,
            //       );
            setState(() {});
            print("playing: ${controller.playerState.isPlaying}");
          },
          icon: Icon(
            controller.playerState.isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
            // size: 30,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
            size: Size(MediaQuery.of(context).size.width * 0.5, 30),
            playerController: controller,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Colors.white54,
              liveWaveColor: Colors.white,
              spacing: 6,
              showSeekLine: false,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
