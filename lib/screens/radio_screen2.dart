import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../radio_provider.dart';


class RadioScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final radioProvider = Provider.of<RadioProvider>(context);

    if (radioProvider.radioUrls.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Radio 2'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Radio 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://r.resimlink.com/Dcx1mRNUA-Hd.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Slow',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    radioProvider.playRadio(radioProvider.radioUrls[1]);
                  },
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(Icons.stop),
                  onPressed: radioProvider.stopRadio,
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(Icons.pause),
                  onPressed: radioProvider.togglePlayPause,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Volume'),
            Slider(
              value: radioProvider.audioPlayer.volume,
              onChanged: (value) {
                radioProvider.setVolume(value);
              },
              min: 0,
              max: 1,
            ),
          ],
        ),
      ),
    );
  }
}
