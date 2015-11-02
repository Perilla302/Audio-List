//
//  ViewController.m
//  Audio List
//
//  Created by Hongjin Su on 10/31/15.
//  Copyright © 2015 Hongjin Su. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview_audioList;
@property (strong, nonatomic) AVAudioRecorder *recoder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSMutableArray *array_fileNames;
@property (strong, nonatomic) NSMutableArray *array_recorderUrls;
@property (strong, nonatomic) NSString *currentFileName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _array_recorderUrls = [[NSMutableArray alloc] init];
    _array_fileNames = [[NSMutableArray alloc] init];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ButtonAction_StartRecording:(id)sender {
    
    _currentFileName = [NSString stringWithFormat:@"MyAudioFile%lu.m4a", _array_fileNames.count + 1];
    NSArray  *path = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject],_currentFileName, nil];
    NSURL *audioUrl = [NSURL fileURLWithPathComponents:path];
    NSLog(@"the audio path is %@", audioUrl);
    
    //creating session
    AVAudioSession *recordSession = [AVAudioSession sharedInstance];
    [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSMutableDictionary *recordSetting =[[NSMutableDictionary alloc]init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.00] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    _recoder = [[AVAudioRecorder alloc]initWithURL:audioUrl settings:recordSetting error:nil];
    _recoder.delegate = self;
    _recoder.meteringEnabled = YES;
    [_recoder prepareToRecord];
    
    if (_player.playing) {
        [_player stop];
    }
    if (!_recoder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [_recoder record];
        NSLog(@"Recording is started");
    }
    else
    {
        [_recoder pause];
    }

}

- (IBAction)ButtonAction_StopRecording:(id)sender {
    
    [_recoder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    [_array_recorderUrls addObject:_recoder.url];
    NSLog(@"url: %@", _recoder.url);
    [_array_fileNames addObject:_currentFileName];
    NSLog(@"current name: %@", _currentFileName);
    NSLog(@"filename list: %@", [_array_fileNames description]);
    NSLog(@"recorder url list: %@", [_array_recorderUrls description]);
    NSLog(@"Recording is Stopped");

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _array_fileNames.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *myCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AudioCell"];
    myCell.textLabel.text = [_array_fileNames objectAtIndex:indexPath.row];
    NSURL *currentUrl = [_array_recorderUrls objectAtIndex:indexPath.row];

    if (!_recoder.recording) {
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:currentUrl error:nil];
        _player.delegate = self;
        [_player play];
    }
    return myCell;
}

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"Done with playing the audio file");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableview_audioList reloadData];
    });
}

@end
