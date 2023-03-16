## Hls-ffmpeg

This project intends to download a video from Google Drive, make HLS assets with segments, and extract the audio. Then create a master playlist for videos with different resolutions to different bandwidths, and make another playlist for the audio.

Including the file server with Golang for local/internal live streaming

### Technologies

1. Bash
2. FFMPEG
3. Curl
4. Golang

### Prerequisite 

I suppose that the FFMPEG has been installed.

### How to run the script?

You can choose between the following, just Open the terminal and type.

1. 

``` sh
sh run.sh
```

2. Or run it manually

``` sh
chmod +x script.sh
```

, And

``` sh
sh script.sh
```

### The output after execution

* After the execution, you will find the following directories contains different HLS segments with different resolution and bitrate and are named in the directory

    1. video_6000k/
    2. video_4500k/
    3. video_3000k/
    4. video_2000k/
    5. video_1100k/

* Master playlist for the videos `master.m3u8` with different resolutions to different bandwidths

* Master playlist for the audio `audio_.m3u8` for the audio to all HLS segments

* `Logs` directories for logs of (videos, audios, file server, FFmpeg)

### How will it look like after execution in treeview

``` 
├── Readme.md
├── audio
│   ├── video_000.mp3
│   ├── video_001.mp3
│   ├── video_002.mp3
│   ├── video_003.mp3
│   ├── video_004.mp3
│   ├── video_005.mp3
│   └── video_006.mp3
├── audio_.m3u8
├── config.sh
├── file_server.go
├── input.mp4
├── logs
│   ├── audio_err.txt
│   ├── audio_log.txt
│   ├── download_log.txt
│   ├── server_log.txt
│   └── video_log.txt
├── master.m3u8
├── run.sh
├── script.sh
├── video_1100k
│   ├── video_000.ts
│   ├── video_001.ts
│   ├── video_002.ts
│   ├── video_003.ts
│   ├── video_004.ts
│   ├── video_005.ts
│   └── video_006.ts
├── video_1100k.m3u8
├── video_2000k
│   ├── video_000.ts
│   ├── video_001.ts
│   ├── video_002.ts
│   ├── video_003.ts
│   ├── video_004.ts
│   ├── video_005.ts
│   └── video_006.ts
├── video_2000k.m3u8
├── video_3000k
│   ├── video_000.ts
│   ├── video_001.ts
│   ├── video_002.ts
│   ├── video_003.ts
│   ├── video_004.ts
│   ├── video_005.ts
│   └── video_006.ts
├── video_3000k.m3u8
├── video_4500k
│   ├── video_000.ts
│   ├── video_001.ts
│   ├── video_002.ts
│   ├── video_003.ts
│   ├── video_004.ts
│   ├── video_005.ts
│   └── video_006.ts
├── video_4500k.m3u8
├── video_6000k
│   ├── video_000.ts
│   ├── video_001.ts
│   ├── video_002.ts
│   ├── video_003.ts
│   ├── video_004.ts
│   ├── video_005.ts
│   └── video_006.ts
└── video_6000k.m3u8
```

### How to open the master playlist?

You will find the following message at the terminal. 

> Please open http://localhost:8081/master.m3u8 at `Safari` or `VLC` File > Open Network > URL

> Or Open with VLC `master.m3u8`
> Also, you can run `audio_.m3u8` by double-clicking on it to run with Music on Mac os.
