//
//  JSMessagesViewController.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSMessagesViewController.h"
#import "NSString+JSMessagesView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "UIColor+JSMessagesView.h"
#import "JSDismissiveTextView.h"

#define INPUT_HEIGHT 46.0f

@interface JSMessagesViewController () <JSDismissiveTextViewDelegate, VoiceRecorderBaseVCDelegate>

- (void)setup;

@end



@implementation JSMessagesViewController

#pragma mark - Initialization
- (void)setup
{
    if([self.view isKindOfClass:[UIScrollView class]]) {
        // fix for ipad modal form presentations
        ((UIScrollView *)self.view).scrollEnabled = NO;
    }
    
    self.chatVoiceTecorderVC = [[ChatVoiceRecorderVC alloc] init];
    self.chatVoiceTecorderVC.vrbDelegate = self;
    
    CGSize size = self.view.frame.size;
	
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, size.width, size.height - INPUT_HEIGHT);
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	
	UIButton* mediaButton = nil;
    UIButton* changeMadeButton = nil;
    if (kAllowsVidio) {
        UIImage* imageUP = [UIImage imageNamed:@"ToolViewInputVoice"];
        UIImage* imageDown = [UIImage imageNamed:@"ToolViewInputVoiceHL"];
        CGRect frame = CGRectMake(4, 0, imageUP.size.width, imageUP.size.height);
        CGFloat yHeight = (INPUT_HEIGHT - frame.size.height) / 2.0f;
		frame.origin.y = yHeight;
        
        changeMadeButton = [[UIButton alloc] initWithFrame:frame];
        [changeMadeButton setBackgroundImage:imageUP forState:UIControlStateNormal];
        [changeMadeButton setBackgroundImage:imageDown forState:UIControlStateHighlighted];
        
        [changeMadeButton addTarget:self action:@selector(ChangeMadeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
	if (kAllowsMedia)
	{
		// set up the image and button frame
		UIImage* image = [UIImage imageNamed:@"PhotoIcon"];
		CGRect frame = CGRectMake(4+ 35.5, 0, image.size.width, image.size.height);
		CGFloat yHeight = (INPUT_HEIGHT - frame.size.height) / 2.0f;
		frame.origin.y = yHeight;
		
		// make the button
		mediaButton = [[UIButton alloc] initWithFrame:frame];
		[mediaButton setBackgroundImage:image forState:UIControlStateNormal];
		
		// button action
		[mediaButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	
    CGRect inputFrame = CGRectMake(0.0f, size.height - INPUT_HEIGHT, size.width, INPUT_HEIGHT);
    self.inputToolBarView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    
    // TODO: refactor
    self.inputToolBarView.textView.dismissivePanGestureRecognizer = self.tableView.panGestureRecognizer;
    self.inputToolBarView.textView.keyboardDelegate = self;
    
    self.inputToolBarView.textView.placeHolder = @"说点什么呢？";
    
    UIButton *sendButton = [self sendButton];
    sendButton.enabled = NO;
    sendButton.frame = CGRectMake(self.inputToolBarView.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f);
    [sendButton addTarget:self
                   action:@selector(sendPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.inputToolBarView setSendButton:sendButton];
    [self.view addSubview:self.inputToolBarView];
    
    /* 初始化 previousTextViewContentHeight */
    if(!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = 35.5f;
    
    if (kAllowsVidio) {
        CGRect frame = self.inputToolBarView.sendButton.frame;
		frame.size.width -= 16;
		frame.origin.x += 16;
		self.inputToolBarView.sendButton.frame = frame;
		
		// add the changeMade button
		[self.inputToolBarView addSubview:changeMadeButton];
        
		// move the tet view over
		frame = self.inputToolBarView.textView.frame;
		frame.origin.x += changeMadeButton.frame.size.width + changeMadeButton.frame.origin.x;
		frame.size.width -= changeMadeButton.frame.size.width + changeMadeButton.frame.origin.x;
		frame.size.width += 16;		// from the send button adjustment above
		self.inputToolBarView.textView.frame = frame;
    }
    
	if (kAllowsMedia)
	{
		// adjust the size of the send button to balance out more with the camera button on the other side.
		CGRect frame = self.inputToolBarView.sendButton.frame;
//		frame.size.width -= 16;
//		frame.origin.x += 16;
//		self.inputToolBarView.sendButton.frame = frame;
		
		// add the camera button
		[self.inputToolBarView addSubview:mediaButton];
        
		// move the tet view over
		frame = self.inputToolBarView.textView.frame;
		frame.origin.x += mediaButton.frame.size.width;// + mediaButton.frame.origin.x;
		frame.size.width -= mediaButton.frame.size.width;// + mediaButton.frame.origin.x;
		//frame.size.width += 16;		// from the send button adjustment above
		self.inputToolBarView.textView.frame = frame;
	}
    
    self.voiceBtn = [[UIButton alloc] initWithFrame:self.inputToolBarView.textView.frame];
    [self.voiceBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.voiceBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    self.voiceBtn.layer.cornerRadius = 5.0f;
    self.voiceBtn.layer.borderWidth = 1.0f;
    self.voiceBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.voiceBtn.backgroundColor = [UIColor lightGrayColor];
    self.voiceBtn.hidden = YES;
    /* 按下按钮 */
    [self.voiceBtn addTarget:self action:@selector(A:) forControlEvents:UIControlEventTouchDown];
    /* 弹起按钮 */
    [self.voiceBtn addTarget:self action:@selector(B:) forControlEvents:UIControlEventTouchUpInside];
    /* 按钮内移动 */
    [self.voiceBtn addTarget:self action:@selector(F:) forControlEvents:UIControlEventTouchDragInside];
    /* 移动到按钮外 */
    [self.voiceBtn addTarget:self action:@selector(C:) forControlEvents:UIControlEventTouchDragOutside];
    /* 移动到按钮外 弹起 */
    [self.voiceBtn addTarget:self action:@selector(D:) forControlEvents:UIControlEventTouchUpOutside];
    [self.inputToolBarView addSubview:self.voiceBtn];
    [self setBackgroundColor:[UIColor messagesBackgroundColor]];
}

- (void)A:(UIButton *)SENDER{
    NSLog(@"按下按钮");
    //设置文件名
    NSString *_voiceStr = [VoiceRecorderBaseVC getCurrentTimeString];
    //开始录音
    [self.chatVoiceTecorderVC beginRecordByFileName:_voiceStr];
}

- (void)B:(UIButton *)SNEDER{
    //结束录音发送消息
    [self.chatVoiceTecorderVC touchEnded:CGPointZero];
    NSLog(@"弹起按钮");
}

- (void)C:(UIButton *)SENDER{
    NSLog(@"按钮外移动");
    //显示取消状态
    CGPoint _movePoint = CGPointZero;
    _movePoint.y = [[UIScreen mainScreen] bounds].size.height-70 - 20;
    [self.chatVoiceTecorderVC touchMoved:_movePoint];
}

- (void)D:(UIButton *)SNEDER{
    NSLog(@"按钮外弹起");
    //执行取消
    [self.chatVoiceTecorderVC touchEnded:CGPointZero];
}

- (void)F:(UIButton *)SENDER{
    NSLog(@"按钮范围内移动");
    //取消删除
    CGPoint _movePoint = CGPointZero;
    _movePoint.y = [[UIScreen mainScreen] bounds].size.height-70 + 20;
    [self.chatVoiceTecorderVC touchMoved:_movePoint];
}



- (void)ChangeMadeBtnClick:(UIButton *)sender {
    self.voiceBtn.hidden = !self.voiceBtn.hidden;
    NSString *upImageName;
    NSString *downImageName;
    if (self.voiceBtn.hidden) {
        upImageName = @"ToolViewInputVoice";
        downImageName = @"ToolViewInputVoiceHL";
        
    }else{
        upImageName = @"ToolViewInputText";
        downImageName = @"ToolViewInputTextHL";
    }
    UIImage* imageUP = [UIImage imageNamed:upImageName];
    UIImage* imageDown = [UIImage imageNamed:downImageName];
    [sender setBackgroundImage:imageUP forState:UIControlStateNormal];
    [sender setBackgroundImage:imageDown forState:UIControlStateHighlighted];
    
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self scrollToBottomAnimated:NO];
    
    
    _originalTableViewContentInset = self.tableView.contentInset;
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputToolBarView resignFirstResponder];
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", self.class);
}

- (void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
    self.tableView = nil;
    self.voiceBtn = nil;
    self.chatVoiceTecorderVC = nil;
    self.inputToolBarView = nil;
}

#pragma mark - View rotation
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender
{
    [self.delegate sendPressed:sender
                      withText:[self.inputToolBarView.textView.text trimWhitespace]];
}


- (void)cameraAction:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraPressed:)]){
        [self.delegate cameraPressed:sender];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
    JSBubbleMessageStyle bubbleStyle = [self.delegate messageStyleForRowAtIndexPath:indexPath];
    JSBubbleMediaType mediaType = [self.delegate messageMediaTypeForRowAtIndexPath:indexPath];
    JSAvatarStyle avatarStyle = [self.delegate avatarStyle];
    
    BOOL hasTimestamp = [self shouldHaveTimestampForRowAtIndexPath:indexPath];
    BOOL hasAvatar = [self shouldHaveAvatarForRowAtIndexPath:indexPath];
    
    NSString *CellID = [NSString stringWithFormat:@"MessageCell_%d_%d_%d_%d", type, bubbleStyle, hasTimestamp, hasAvatar];
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    
    if(!cell)
        cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                                   bubbleStyle:bubbleStyle
                                                   avatarStyle:(hasAvatar) ? avatarStyle : JSAvatarStyleNone mediaType:mediaType
                                                  hasTimestamp:hasTimestamp
                                               reuseIdentifier:CellID];
    
    if(hasTimestamp)
        [cell setTimestamp:[self.dataSource timestampForRowAtIndexPath:indexPath]];
    
    if(hasAvatar) {
        switch (type) {
            case JSBubbleMessageTypeIncoming:
                [cell setAvatarImage:[self.dataSource avatarImageForIncomingMessageAtIndexPath:indexPath]];
                break;
                
            case JSBubbleMessageTypeOutgoing:
                [cell setAvatarImage:[self.dataSource avatarImageForOutgoingMessageAtIndexPath:indexPath]];
                break;
        }
    }
    
	if (kAllowsMedia)
		[cell setMedia:[self.dataSource dataForRowAtIndexPath:indexPath]];
    
    [cell setMessage:[self.dataSource textForRowAtIndexPath:indexPath]];
    [cell setBackgroundColor:tableView.backgroundColor];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self.delegate messageMediaTypeForRowAtIndexPath:indexPath]){
        return [JSBubbleMessageCell neededHeightForText:[self.dataSource textForRowAtIndexPath:indexPath]
                                              timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                                 avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]];
    }else{
        return [JSBubbleMessageCell neededHeightForImage:[self.dataSource dataForRowAtIndexPath:indexPath]
                                               timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                                  avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate selectCellAtIndexPath:indexPath];
}

#pragma mark - Messages view controller
- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.delegate timestampPolicy]) {
        case JSMessagesViewTimestampPolicyAll:
            return YES;
            
        case JSMessagesViewTimestampPolicyAlternating:
            return indexPath.row % 2 == 0;
            
        case JSMessagesViewTimestampPolicyEveryThree:
            return indexPath.row % 3 == 0;
            
        case JSMessagesViewTimestampPolicyEveryFive:
            return indexPath.row % 5 == 0;
            
        case JSMessagesViewTimestampPolicyCustom:
            if([self.delegate respondsToSelector:@selector(hasTimestampForRowAtIndexPath:)])
                return [self.delegate hasTimestampForRowAtIndexPath:indexPath];
            
        default:
            return NO;
    }
}

- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.delegate avatarPolicy]) {
        case JSMessagesViewAvatarPolicyIncomingOnly:
            return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming;
            
        case JSMessagesViewAvatarPolicyBoth:
            return YES;
            
        case JSMessagesViewAvatarPolicyNone:
        default:
            return NO;
    }
}

- (void)finishSend
{
    [self.inputToolBarView.textView setText:nil];
    [self textViewDidChange:self.inputToolBarView.textView];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
    self.tableView.separatorColor = color;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}


- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated
{
	[self.tableView scrollToRowAtIndexPath:indexPath
						  atScrollPosition:position
								  animated:animated];
}


#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
	
    if(!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToBottomAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    NSLog(@"--------------------------------%f", self.previousTextViewContentHeight);
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    
    
    if(changeInHeight != 0.0f) {
        //        if(!isShrinking)
        //            [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                                                    0.0f,
                                                                    self.tableView.contentInset.bottom + changeInHeight,
                                                                    0.0f);
                             
                             self.tableView.contentInset = insets;
                             self.tableView.scrollIndicatorInsets = insets;
                             [self scrollToBottomAnimated:NO];
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.inputToolBarView.frame;
                             self.inputToolBarView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
    
    self.inputToolBarView.sendButton.enabled = ([textView.text trimWhitespace].length > 0);
}

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.inputToolBarView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         // for ipad modal form presentations
                         CGFloat messageViewFrameBottom = self.view.frame.size.height - INPUT_HEIGHT;
                         if(inputViewFrameY > messageViewFrameBottom)
                             inputViewFrameY = messageViewFrameBottom;
                         
                         self.inputToolBarView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                  inputViewFrameY,
                                                                  inputViewFrame.size.width,
                                                                  inputViewFrame.size.height);
                         
                         UIEdgeInsets insets = self.originalTableViewContentInset;
                         insets.bottom = self.view.frame.size.height - self.inputToolBarView.frame.origin.y - inputViewFrame.size.height;
                         
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - Dismissive text view delegate
- (void)keyboardDidScrollToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = self.inputToolBarView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.inputToolBarView.frame = inputViewFrame;
}

- (void)keyboardWillBeDismissed
{
    CGRect inputViewFrame = self.inputToolBarView.frame;
    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
    self.inputToolBarView.frame = inputViewFrame;
}

#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"收到录音回调");
    [self.delegate VCRecordFinish:_filePath fileName:_fileName];
}

//- (void)keyboardWillSnapBackToPoint:(CGPoint)pt
//{
//    CGRect inputViewFrame = self.inputToolBarView.frame;
//    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
//    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
//    self.inputToolBarView.frame = inputViewFrame;
//    
//    
//}

@end