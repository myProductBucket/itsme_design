//
//  PatternDesignViewController.m
//  It'sMe
//
//  Created by Karl Faust on 1/29/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "PatternDesignViewController.h"
#import "ClothDesignViewController.h"

#define LEFTTAG 1
#define RIGHTTAG 2

@interface PatternDesignViewController ()<UIScrollViewDelegate>{
    BOOL isLeftViewShown;
    BOOL isRightViewShown;
    BOOL isCloseButton;
    
    NSMutableArray *clothNames;//Cloth
    NSMutableArray *clothImages;
    NSMutableArray *hairNames;//Hair
    NSMutableArray *hairImages;
    NSMutableArray *bagNames;//Bag
    NSMutableArray *bagImages;
    NSMutableArray *shoeNames;//Shoe
    NSMutableArray *shoeImages;
    NSMutableArray *leftNames;//
    NSMutableArray *leftImages;
    
    NSMutableArray *backgroundNames;//Background
    NSMutableArray *backgroundImages;
    NSMutableArray *characterNames;//Character
    NSMutableArray *characterImages;
    NSMutableArray *rightNames;//
    NSMutableArray *rightImages;
    
    //--Studio View
    
    //Left View
    UIView *leftSlideView;
    UIButton *leftItemName;
    UIScrollView *leftScrollV;
    NSInteger leftSelectedIndex;//indicatin whether you select the bag or cloth or shoe or hair
    
    //Right View
    UIView *rightSlideView;
    UIButton *rightItemName;
    UIScrollView *rightScrollV;
    UIImage *rightSelectedImage;//after tapping image
    NSInteger rightSelectedIndex;//indicating whether you select the background or character6
    
    //items index
    NSInteger leftIndex;
    NSInteger leftCount;
    NSInteger rightIndex;
    NSInteger rightCount;
    
    
    //displaying items retrieved
    NSMutableArray *characters;
    NSMutableArray *clothes;
    NSMutableArray *bags;
    NSMutableArray *hairs;
    NSMutableArray *shoes;
}
//--Studio View
@property (weak, nonatomic) IBOutlet UIView *studioView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
//--Left

@property (weak, nonatomic) IBOutlet UIView *leftSideView;

//--Right

@property (weak, nonatomic) IBOutlet UIView *rightSideView;

@end

@implementation PatternDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isLeftViewShown = false;
    isRightViewShown = false;
    isCloseButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hiding left/right View
//    [self.leftSlideView setHidden:true];
//    [self.leftSlideView setFrame:CGRectMake( - self.leftSlideView.frame.size.width, 0, self.leftSlideView.frame.size.width, self.leftSlideView.frame.size.height)];
//    [self hideLeftSlideView];
    
//    [self.rightSlideView setHidden:true];
//    [self.rightSlideView setFrame:CGRectMake( self.rightSlideView.frame.size.width * 2, 0, self.rightSlideView.frame.size.width, self.rightSlideView.frame.size.height)];
    
    [leftSlideView setHidden:true];
    
    [rightSlideView setHidden:true];
    
    [leftItemName.titleLabel setFont:[UIFont systemFontOfSize:leftItemName.frame.size.height / 3]];
    [rightItemName.titleLabel setFont:[UIFont systemFontOfSize:	rightItemName.frame.size.height / 3]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initLeftSlideView];
    [self initRightSlideView];
    
    //Init items info
    [self initItemsInfo];
    
    [self loadCustomItems];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Custom Event

#pragma mark - Left Event

- (void)leftBackTouchUp: (UIButton *)sender {
    NSLog(@"leftScrollV.contentOffset.x---%f", leftScrollV.contentOffset.x);
    NSLog(@"%f", leftScrollV.frame.size.width);
    
    if (leftIndex < (leftCount - 1)) {
        leftIndex++;
//        [leftItemName setTitle:leftNames[leftIndex] forState:UIControlStateNormal];
        [leftScrollV setContentOffset:CGPointMake(leftIndex * leftScrollV.frame.size.width, 0) animated:true];
    }
}

- (void)leftForwardTouchUp: (UIButton *)sender {
    
    if (leftIndex > 0) {
        leftIndex--;
//        [leftItemName setTitle:leftNames[leftIndex] forState:UIControlStateNormal];
        [leftScrollV setContentOffset:CGPointMake(leftIndex * leftScrollV.frame.size.width, 0) animated:true];
    }
}

- (void)leftCloseTouchUp:(UIButton *)sender {
    isCloseButton = YES;
    
    [self hideLeftSlideView];
}

- (IBAction)leftSideButtonsTouchUp:(UIButton *)sender {
    isCloseButton = NO;
    
    //remove the items from Left Scroll View
    [self removeAllSubViewsForLeftScrollView];
    
    if (isLeftViewShown) {
        [self hideLeftSlideView];
    }else{
        [self showLeftSlideView];
    }
    
    leftIndex = 0;
    leftSelectedIndex = sender.tag;
    [leftScrollV setContentOffset:CGPointMake(0, 0)];
    
    switch (sender.tag) {
        case 1://Cloth
            NSLog(@"choosing cloth...");
            [self addClothItems];
            break;
        case 2://Hair
            NSLog(@"choosing hair...");
            [self addHairItems];
            break;
        case 3://Bag
            NSLog(@"choosing bag...");
            [self addBagItems];
            break;
        case 4://Shoe
            NSLog(@"choosing shoe...");
            [self addShoeItems];
            break;
        default:
            break;
    }
}

#pragma mark - Right Event

- (void)rightBackTouchUp: (UIButton *)sender{
    if (rightIndex < (rightCount - 1)) {
        rightIndex++;
//        [rightItemName setTitle:rightNames[rightIndex] forState:UIControlStateNormal];
        [rightScrollV setContentOffset:CGPointMake(rightIndex * rightScrollV.frame.size.width, 0) animated:true];
    }
}

- (void)rightForwardTouchUp: (UIButton *)sender{
    if (rightIndex > 0) {
        rightIndex--;
//        [rightItemName setTitle:rightNames[rightIndex] forState:UIControlStateNormal];
        [rightScrollV setContentOffset:CGPointMake(rightIndex * rightScrollV.frame.size.width, 0) animated:true];
    }
}

- (void)rightConfirmTouchUp:(UIButton *)sender {
    if (rightSelectedIndex == 3) {
        return;
    }
    
    [self addRightItemImageToStudio];
}

- (void)rightCloseTouchUp:(id)sender {
    isCloseButton = YES;
    
    [self hideRightSlideView];
}

- (IBAction)rightSideButtonsTouchUp:(UIButton *)sender {
    isCloseButton = NO;

//    [self addBackgroundItems];
    
    if (sender.tag == 3) {//Design
        NSLog(@"designing...");
        [self showClothDesignViewController];
        isCloseButton = YES;
        [self hideLeftSlideView];
        [self hideRightSlideView];
        
        return;
    }
    
    if (isRightViewShown) {
        [self hideRightSlideView];
    }else{
        [self showRightSlideView];
    }
    
    rightIndex = 0;
    rightSelectedIndex = sender.tag;
    [rightScrollV setContentOffset:CGPointMake(0, 0)];
    
    switch (sender.tag) {
        case 1://Background
            NSLog(@"choosing background...");
            [self addBackgroundItems];
            break;
        case 2://Character
            NSLog(@"choosing character...");
            [self addCharacterItems];
            break;
        case 3://Design
            
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex;
    currentIndex = [self getCycleNumber:(NSInteger)scrollView.contentOffset.x other:(NSInteger)scrollView.frame.size.width];
    if (scrollView.tag == LEFTTAG) {
        leftIndex = currentIndex;
//        [leftItemName setTitle:leftNames[currentIndex] forState:UIControlStateNormal];
    }else{
        rightIndex = currentIndex;
//        [rightItemName setTitle:rightNames[currentIndex] forState:UIControlStateNormal];
    }
}

#pragma mark - Custom Method

- (void)characterResize: (UIPinchGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
}

- (void)characterMove: (UIPanGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
    CGPoint touchPoint = [sender locationInView:[self studioView]];
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [sender.view setCenter:touchPoint];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)characterTap: (UITapGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
}

- (void)characterTapForDel: (UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.view.transform = CGAffineTransformScale(sender.view.transform, 0.1, 0.1);
        [sender.view setAlpha:0.1];
    } completion:^(BOOL finished) {
        [sender.view removeFromSuperview];
    }];
}

- (NSInteger)getCycleNumber: (NSInteger)one other: (NSInteger)two {
    NSInteger result;
    if ((one % two) > (two / 2)) {
        result = one / two + 1;
    }else{
        result = one / two;
    }
    
    return result;
}

- (void)showClothDesignViewController {
    ClothDesignViewController *clothVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ClothDesignViewController"];
    [self presentViewController:clothVC animated:true completion:nil];
}

- (void)hideLeftSlideView {
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [leftSlideView setFrame:CGRectMake( - leftSlideView.frame.size.width, 0, leftSlideView.frame.size.width, leftSlideView.frame.size.height)];
    } completion:^(BOOL finished) {
        if (isCloseButton) {//if current button is close, hide leftsideview
            [leftSlideView setHidden:true];
            isLeftViewShown = false;
        }else{//if not, show again
            [self showLeftSlideView];
        }
    }];
}

- (void)showLeftSlideView {
    [leftSlideView setHidden:false];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [leftSlideView setFrame:CGRectMake( 0, 0, leftSlideView.frame.size.width, leftSlideView.frame.size.height)];
    } completion:^(BOOL finished) {
        isLeftViewShown = true;
    }];
}

- (void)hideRightSlideView {
    [self removeAllSubViewsForRightScrollView];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [rightSlideView setFrame:CGRectMake( rightSlideView.frame.size.width * 2, 0, rightSlideView.frame.size.width, rightSlideView.frame.size.height)];
    } completion:^(BOOL finished) {
        if (isCloseButton) {//if current button is close button, hide rightsideview
            [rightSlideView setHidden:true];
            isRightViewShown = false;
        }else{//if not, show again.
            [self showRightSlideView];
        }
    }];
}

- (void)showRightSlideView {
    [rightSlideView setHidden:false];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [rightSlideView setFrame:CGRectMake( rightSlideView.frame.size.width, 0, rightSlideView.frame.size.width, rightSlideView.frame.size.height)];
    } completion:^(BOOL finished) {
        isRightViewShown = true;
    }];
}

- (void)loadCustomItems {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *documentArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSArray *pngFiles = [documentArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasSuffix:EXTENSION];
    }]];
//    NSMutableArray *filePaths = [@[] mutableCopy];
    for (NSString *fileName in pngFiles) {
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        if ([fileName containsString:CLOTH_PREFIX]) {
            [clothImages insertObject:filePath atIndex:0];
            [clothNames insertObject:[fileName substringWithRange:NSMakeRange(0, fileName.length - 4)] atIndex:0];
        }else if ([fileName containsString:HAIR_PREFIX]) {
            [hairImages insertObject:filePath atIndex:0];
            [hairNames insertObject:[fileName substringWithRange:NSMakeRange(0, fileName.length - 4)] atIndex:0];
        }else if ([fileName containsString:SHOE_PREFIX]) {
            [shoeImages insertObject:filePath atIndex:0];
            [shoeNames insertObject:[fileName substringWithRange:NSMakeRange(0, fileName.length - 4)] atIndex:0];
        }else {
            [bagImages insertObject:filePath atIndex:0];
            [bagNames insertObject:[fileName substringWithRange:NSMakeRange(0, fileName.length - 4)] atIndex:0];
        }
    }
}

- (void)initItemsInfo {
    characters = [[NSMutableArray alloc] init];
    clothes = [[NSMutableArray alloc] init];
    bags = [[NSMutableArray alloc] init];
    shoes = [[NSMutableArray alloc] init];
    hairs = [[NSMutableArray alloc] init];
    
    leftIndex = 0;
    leftCount = 0;
    rightIndex = 0;
    rightCount = 0;
    
    backgroundNames = [[NSMutableArray alloc] init];
    bagNames = [[NSMutableArray alloc] init];
    characterNames = [[NSMutableArray alloc] init];
    clothNames = [[NSMutableArray alloc] init];
    hairNames = [[NSMutableArray alloc] init];
    shoeNames = [[NSMutableArray alloc] init];
    
    backgroundImages = [[NSMutableArray alloc] init];
    bagImages = [[NSMutableArray alloc] init];
    characterImages = [[NSMutableArray alloc] init];
    clothImages = [[NSMutableArray alloc] init];
    hairImages = [[NSMutableArray alloc] init];
    shoeImages = [[NSMutableArray alloc] init];
    
    //get the resource path
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //get the background images path
    NSString * itemsPath = [resourcePath stringByAppendingPathComponent:@"/background/"];
    NSArray* items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        [backgroundImages addObject:[itemsPath stringByAppendingPathComponent:fileName]];
        [backgroundNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
    
    //get the bag images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/bag/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [bagImages addObject:[itemsPath stringByAppendingPathComponent:(NSString *)obj]];
        [bagNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
    
    //get the character images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/character/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [characterImages addObject:[itemsPath stringByAppendingPathComponent:(NSString *)obj]];
        [characterNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
    
    //get the cloth images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/cloth/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [clothImages addObject:[itemsPath stringByAppendingPathComponent:(NSString *)obj]];
        [clothNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
    
    //get the hair images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/hair/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [hairImages addObject:[itemsPath stringByAppendingPathComponent:(NSString *)obj]];
        [hairNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
    
    //get the shoe images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/shoe/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                        error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [shoeImages addObject:[itemsPath stringByAppendingPathComponent:(NSString *)obj]];
        [shoeNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];
}

- (void)removeAllSubViewsForLeftScrollView {
    for (UIView *subV in leftScrollV.subviews) {
        [subV removeFromSuperview];
    }
}

- (void)removeAllSubViewsForRightScrollView {
    for (UIView *subV in rightScrollV.subviews) {
        [subV removeFromSuperview];
    }
}

- (void)addBackgroundItems {
    CGFloat wid = rightScrollV.frame.size.width;
    CGFloat hei = rightScrollV.frame.size.height;
    
    [rightScrollV setContentSize:CGSizeMake(wid * backgroundImages.count, hei)];
    NSInteger i = 0;
    
    rightCount = backgroundImages.count;
    rightImages = [backgroundImages mutableCopy];
    rightNames = [backgroundNames mutableCopy];
    
    [rightItemName setTitle:@"Background" forState:UIControlStateNormal];
    if (rightNames.count > 0) {
//        [rightItemName setTitle:rightNames[0] forState:UIControlStateNormal];
    }
    
    for (NSString *itemName in backgroundImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(wid / 4 + i * wid, 0, wid / 2, hei)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRightImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        [imgV addGestureRecognizer:tapGesture];
        
        [rightScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)tapRightImage: (UITapGestureRecognizer *)sender {
    [self addRightItemImageToStudio];
}

- (void)addRightItemImageToStudio {
    rightSelectedImage = [UIImage imageNamed:rightImages[rightIndex]];
    
    if (rightSelectedIndex == 1) {//background
        [self.backgroundImageView setAlpha:1];
        [self.backgroundImageView setImage:[UIImage imageNamed:rightNames[rightIndex]]];
    }else if (rightSelectedIndex == 2) {//character
        CGFloat hei = self.view.frame.size.height / 2;
        CGFloat wid = rightSelectedImage.size.width * hei / rightSelectedImage.size.height;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 10, wid, hei)];
        [imageV setImage:rightSelectedImage];
        
        //adding gesture recognizer
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(characterResize:)];
        [imageV addGestureRecognizer:pinchGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(characterMove:)];
        [imageV addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(characterTap:)];
        [imageV addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapGestureForDel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(characterTapForDel:)];
        [imageV addGestureRecognizer:tapGestureForDel];
        
        [imageV setUserInteractionEnabled:YES];
        
        [self addCharactersInStudio:imageV];
        [characters addObject:imageV];//-----------------
    }
    
    isCloseButton = YES;
    [self hideRightSlideView];
}

- (void)addCharacterItems {
    CGFloat wid = rightScrollV.frame.size.width;
    CGFloat hei = rightScrollV.frame.size.height;
    
    [rightScrollV setContentSize:CGSizeMake(wid * characterImages.count, hei)];
    NSInteger i = 0;
    
    rightCount = characterImages.count;
    rightImages = [characterImages mutableCopy];
    rightNames = [characterNames mutableCopy];
    
    [rightItemName setTitle:@"Dolls" forState:UIControlStateNormal];
    if (rightNames.count > 0) {
//        [rightItemName setTitle:rightNames[0] forState:UIControlStateNormal];
    }
    
    for (NSString *itemName in characterImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(wid / 4 + i * wid, 0, wid / 2, hei)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRightImage:)];
        [tapGestureRecognizer setNumberOfTapsRequired:2];
        [imgV addGestureRecognizer:tapGestureRecognizer];
//        [imgV setAlpha:0.5];
        
//        if (rightSelectedImage != NULL && rightIndex == i) {
//            [imgV setAlpha:1];
//        }
        
        [rightScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)tapLeftImage: (UITapGestureRecognizer *)sender {
    NSLog(@"long press...");
    
    UIImage *leftSelectedImage = [UIImage imageNamed:leftImages[leftIndex]];
    
    CGFloat hei = self.view.frame.size.height / 4;
    CGFloat wid = leftSelectedImage.size.width * hei / leftSelectedImage.size.height;
    
    UIImageView *copyImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
    [copyImageV setImage:[UIImage imageNamed:leftImages[leftIndex]]];
    [copyImageV setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftItem:)];
    [copyImageV addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeLeftItem:)];
    [copyImageV addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftItem:)];
    [copyImageV addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGestureForDel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftItemForDel:)];
    [tapGestureForDel setNumberOfTapsRequired:2];
    [copyImageV addGestureRecognizer:tapGestureForDel];
    
    CGPoint touchPoint = [sender locationInView:self.studioView];
    if (leftSlideView.frame.origin.x < 0) {
        return;
    }
    
//    [self.studioView addSubview:copyImageV];
    [self addAccessoriesInStudio:copyImageV];
    
    [copyImageV setAlpha:0];
    
    isCloseButton = YES;
    [self hideLeftSlideView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [copyImageV setCenter:touchPoint];
    } completion:^(BOOL finished) {
        [copyImageV setAlpha:1];
    }];
}

- (void)addAccessoriesInStudio: (UIImageView *)sender {
//    switch (leftSelectedIndex) {
//        case 1://Cloth
//            NSLog(@"choosing cloth...");
//            if (clothes.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:clothes[clothes.count - 1]];
//            }else if (shoes.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:characters[shoes.count - 1]];
//            }else if (characters.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:characters[characters.count - 1]];
//            }else if (self.studioView.subviews.count > 1) {
//                [self.studioView insertSubview:sender belowSubview:self.studioView.subviews[1]];
//            }else{
//                [self.studioView addSubview:sender];
//            }
//
//            [clothes addObject:sender];
//            break;
//        case 2://Hair
//            NSLog(@"choosing hair...");
//            if (clothes.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:clothes[0]];
//            }else if (characters.count > 0){
//                [self.studioView insertSubview:sender aboveSubview:characters[0]];
//            }else{
//                [self.studioView addSubview:sender];
//            }
//
//            [hairs addObject:sender];
//            break;
//        case 3://Bag
//            NSLog(@"choosing bag...");
//            if (clothes.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:clothes[0]];
//            }else if (characters.count > 0){
//                [self.studioView insertSubview:sender aboveSubview:characters[0]];
//            }else{
//                [self.studioView addSubview:sender];
//            }
//            
//            [bags addObject:sender];
//            break;
//        case 4://Shoe
//            NSLog(@"choosing shoe...");
//            if (clothes.count > 0) {
//                [self.studioView insertSubview:sender aboveSubview:clothes[0]];
//            }else if (characters.count > 0){
//                [self.studioView insertSubview:sender aboveSubview:characters[0]];
//            }else{
//                [self.studioView addSubview:sender];
//            }
//
//            [shoes addObject:sender];
//            break;
//        default:
//            break;
//    }
    [self.studioView addSubview:sender];
}

- (void)addCharactersInStudio: (UIImageView *)sender {
//    if (characters.count > 0) {
//        [self.studioView insertSubview:sender aboveSubview:characters[characters.count - 1]];
//    }
//    else if (self.studioView.subviews.count > 1) {
//        [self.studioView insertSubview:sender belowSubview:self.studioView.subviews[1]];
//    }else{
//        [self.studioView addSubview:sender];
//    }
    [self.studioView addSubview:sender];
}

- (void)moveLeftItem: (UIPanGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
    CGPoint touchPoint = [sender locationInView:[self studioView]];
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [sender.view setCenter:touchPoint];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resizeLeftItem: (UIPinchGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
}

- (void)tapLeftItem: (UITapGestureRecognizer *)sender {
    [self.studioView bringSubviewToFront:sender.view];
}

- (void)tapLeftItemForDel: (UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.view.transform = CGAffineTransformScale(sender.view.transform, 0.1, 0.1);
        [sender.view setAlpha:0.1];
    } completion:^(BOOL finished) {
        [sender.view removeFromSuperview];
    }];
}

- (void)addBagItems {
    CGFloat wid = leftScrollV.frame.size.width;
    CGFloat hei = leftScrollV.frame.size.height;
    
    [leftScrollV setContentSize:CGSizeMake(wid * bagImages.count, hei)];
    NSInteger i = 0;
    
    leftCount = bagImages.count;
    leftImages = [bagImages mutableCopy];
    leftNames = [bagNames mutableCopy];
    
    [leftItemName setTitle:@"Accessories" forState:UIControlStateNormal];
    if (leftNames.count > 0) {
//        [leftItemName setTitle:leftNames[0] forState:UIControlStateNormal];
    }
    
    for (NSString *itemName in bagImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(wid / 4 + i * wid, 0, wid / 2, hei)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        //adding gestures
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
//        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLeftImage:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftImage:)];
        [tapGesture setNumberOfTapsRequired:2];

        [imgV addGestureRecognizer:tapGesture];
        
        [leftScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)addClothItems {
    CGFloat wid = leftScrollV.frame.size.width;
    CGFloat hei = leftScrollV.frame.size.height;
    
    [leftScrollV setContentSize:CGSizeMake(wid * clothImages.count, hei)];
    NSInteger i = 0;
    
    leftCount = clothImages.count;
    leftImages = [clothImages mutableCopy];
    leftNames = [clothNames mutableCopy];
    
    [leftItemName setTitle:@"Clothes" forState:UIControlStateNormal];
    if (leftNames.count > 0) {
//        [leftItemName setTitle:leftNames[0] forState:UIControlStateNormal];
    }
    
    for (NSString *itemName in clothImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i * wid, hei / 4, wid, hei / 2)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        //adding gestures
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        //        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLeftImage:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        
        [imgV addGestureRecognizer:tapGesture];
        
        [leftScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)addHairItems {
    CGFloat wid = leftScrollV.frame.size.width;
    CGFloat hei = leftScrollV.frame.size.height;
    
    [leftScrollV setContentSize:CGSizeMake(wid * hairImages.count, hei)];
    
    leftCount = hairImages.count;
    leftImages = [hairImages mutableCopy];
    leftNames = [hairNames mutableCopy];
    
    [leftItemName setTitle:@"Hair Styles" forState:UIControlStateNormal];
    if (leftNames.count > 0) {
//        [leftItemName setTitle:leftNames[0] forState:UIControlStateNormal];
    }
    
    NSInteger i = 0;
    for (NSString *itemName in hairImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(wid / 4 + i * wid, 0, wid / 2, hei)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        //adding gestures
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        //        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLeftImage:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        
        [imgV addGestureRecognizer:tapGesture];
        
        [leftScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)addShoeItems {
    CGFloat wid = leftScrollV.frame.size.width;
    CGFloat hei = leftScrollV.frame.size.height;
    
    [leftScrollV setContentSize:CGSizeMake(wid * shoeImages.count, hei)];
    NSInteger i = 0;
    
    leftCount = shoeImages.count;
    leftImages = [shoeImages mutableCopy];
    leftNames = [shoeNames mutableCopy];
    
    [leftItemName setTitle:@"Shoes" forState:UIControlStateNormal];
    if (leftNames.count > 0) {
//        [leftItemName setTitle:leftNames[0] forState:UIControlStateNormal];
    }
    
    for (NSString *itemName in shoeImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(wid / 4 + i * wid, 0, wid / 2, hei)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        //adding gestures
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        //        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLeftImage:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLeftImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        
        [imgV addGestureRecognizer:tapGesture];
        
        [leftScrollV addSubview:imgV];
        
        i++;
    }
}

//--------------------------
- (void)initLeftSlideView {
    CGFloat wid = self.view.frame.size.width / 2;
    CGFloat w = self.leftSideView.frame.size.width;
    CGFloat h = self.leftSideView.frame.size.height;
    
    leftSlideView = [[UIView alloc] initWithFrame:CGRectMake( - wid, 0, wid, h)];
    [leftSlideView setBackgroundColor:[UIColor clearColor]];
    //    [self.itemView setFrame:CGRectMake( - wid, self.penView.frame.origin.y, wid, penHei)];//itemView
    
    UIImageView *leftLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [leftLightBlueImageV setImage:[UIImage imageNamed:@"left-panel-blue.png"]];
    [leftLightBlueImageV setBackgroundColor:[UIColor clearColor]];
    [leftSlideView addSubview:leftLightBlueImageV];
    //    [self.leftLightBlueImageV setFrame:CGRectMake(0, 0, penWid, penHei)];
    //-----------------
    UIView *rightLightWhiteV = [[UIView alloc] initWithFrame:CGRectMake(w, 0, wid - w, h)];
    [rightLightWhiteV setBackgroundColor:[UIColor clearColor]];
    //    [self.rigthLightWhiteV setFrame:CGRectMake(penWid, 0, wid - penWid, penHei)];
    
    UIImageView *rightLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid - w, h)];
    [rightLightBlueImageV setImage:[UIImage imageNamed:@"left-panel-white.png"]];
    [rightLightWhiteV addSubview:rightLightBlueImageV];
    //    [self.rightLightBlueImageV setFrame:CGRectMake(0, 0, wid - penWid, penHei)];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 226 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"bt-leftclose.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(leftCloseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:closeButton];
    //    [self.itemCloseButton setFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    
    leftItemName = [[UIButton alloc] initWithFrame:CGRectMake((wid - w - (wid - w) * 192 / 276) / 2, 8, (wid - w) * 192 / 276, h * 49 / 414)];
    [leftItemName setBackgroundImage:[UIImage imageNamed:@"left-label.png"] forState:UIControlStateNormal];
    leftItemName.userInteractionEnabled = NO;
    [leftItemName.titleLabel setFont:[UIFont systemFontOfSize:leftItemName.frame.size.height / 3]];
    [leftItemName setTitle:@"Designs" forState:UIControlStateNormal];
    [rightLightWhiteV addSubview:leftItemName];
    //    [self.itemNameButton setFrame:CGRectMake((wid - penWid) / 4, 0, penWid / 2, penHei * 3 / 8)];
    
    leftScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, h * 65 / 414, (wid - w) * 176 / 276, h * 284 / 414)];
    [leftScrollV setShowsHorizontalScrollIndicator:false];
    [leftScrollV setShowsVerticalScrollIndicator:false];
    [leftScrollV setPagingEnabled:true];
    leftScrollV.delegate = self;
    [leftScrollV setTag:LEFTTAG];
//    [leftScrollV setBackgroundColor:[UIColor blackColor]];
    
    [rightLightWhiteV addSubview:leftScrollV];
    //    [self.itemScrollV setFrame:CGRectMake((wid - penWid) / 4, penHei * 3 / 8, penWid / 2, penHei * 3 / 8)];
    
//    CGRect rightRect;
//    CGRect leftRect;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        rightRect = CGRectMake((wid - w) * 3 / 4 - h / 4, h * 3 / 8, h / 4, h * 3 / 8);
//        leftRect = CGRectMake((wid - w) / 4 , h * 3 / 8, h / 4, h * 3 / 8);
//    }else{
//        rightRect = CGRectMake((wid - w) * 3 / 4, h * 3 / 8, h / 4, h * 3 / 8);
//        leftRect = CGRectMake((wid - w) / 4 - h / 4, h * 3 / 8, h / 4, h * 3 / 8);
//    }
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 176 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"bt-rightnext.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(leftBackTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:rightButton];
    //    [self.leftButton setFrame:CGRectMake((wid - penWid) / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"bt-leftnext.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftForwardTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:leftButton];
    //    [self.rightButton setFrame:CGRectMake((wid - penWid) * 3 / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    [leftSlideView addSubview:rightLightWhiteV];
    
    [self.view insertSubview:leftSlideView belowSubview:self.leftSideView];
}


- (void)initRightSlideView {
    CGFloat wid = self.view.frame.size.width / 2;
    CGFloat w = self.rightSideView.frame.size.width;
    CGFloat h = self.rightSideView.frame.size.height;
    
    rightSlideView = [[UIView alloc] initWithFrame:CGRectMake(wid * 2, 0, wid, h)];
    [rightSlideView setBackgroundColor:[UIColor clearColor]];
    //    [self.itemView setFrame:CGRectMake( - wid, self.penView.frame.origin.y, wid, penHei)];//itemView
    
    UIImageView *rightLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(wid - w, 0, w, h)];
    [rightLightBlueImageV setImage:[UIImage imageNamed:@"right-panel-blue.png"]];
    [rightLightBlueImageV setBackgroundColor:[UIColor clearColor]];
    [rightSlideView addSubview:rightLightBlueImageV];
    //    [self.leftLightBlueImageV setFrame:CGRectMake(0, 0, penWid, penHei)];
    //-----------------
    UIView *rightLightWhiteV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid - w, h)];
    [rightLightWhiteV setBackgroundColor:[UIColor clearColor]];
    //    [self.rigthLightWhiteV setFrame:CGRectMake(penWid, 0, wid - penWid, penHei)];
    
    UIImageView *leftLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid - w, h)];
    [leftLightBlueImageV setImage:[UIImage imageNamed:@"right-panel-white.png"]];
    [rightLightWhiteV addSubview:leftLightBlueImageV];
    //    [self.rightLightBlueImageV setFrame:CGRectMake(0, 0, wid - penWid, penHei)];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"bt-rightclose.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(rightCloseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:closeButton];
    //    [self.itemCloseButton setFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (h - (wid - w) * 150 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"bt_confirm.png"] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(rightConfirmTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:confirmButton];
    
    rightItemName = [[UIButton alloc] initWithFrame:CGRectMake((wid - w - (wid - w) * 192 / 276) / 2, 8, (wid - w) * 192 / 276, h * 49 / 414)];
    [rightItemName setBackgroundImage:[UIImage imageNamed:@"right-label.png"] forState:UIControlStateNormal];
    rightItemName.userInteractionEnabled = NO;
    [rightItemName.titleLabel setFont:[UIFont systemFontOfSize:rightItemName.frame.size.height / 3]];
    [rightLightWhiteV addSubview:rightItemName];
    //    [self.itemNameButton setFrame:CGRectMake((wid - penWid) / 4, 0, penWid / 2, penHei * 3 / 8)];
    
    rightScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, h * 65 / 414, (wid - w) * 176 / 276, h * 284 / 414)];
    [rightScrollV setShowsHorizontalScrollIndicator:false];
    [rightScrollV setShowsVerticalScrollIndicator:false];
    [rightScrollV setPagingEnabled:true];
    rightScrollV.delegate = self;
    [rightScrollV setTag:RIGHTTAG];
//    [rightScrollV setBackgroundColor:[UIColor blackColor]];
    
    [rightLightWhiteV addSubview:rightScrollV];
    //    [self.itemScrollV setFrame:CGRectMake((wid - penWid) / 4, penHei * 3 / 8, penWid / 2, penHei * 3 / 8)];
    
    //    CGRect rightRect;
    //    CGRect leftRect;
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //        rightRect = CGRectMake((wid - w) * 3 / 4 - h / 4, h * 3 / 8, h / 4, h * 3 / 8);
    //        leftRect = CGRectMake((wid - w) / 4 , h * 3 / 8, h / 4, h * 3 / 8);
    //    }else{
    //        rightRect = CGRectMake((wid - w) * 3 / 4, h * 3 / 8, h / 4, h * 3 / 8);
    //        leftRect = CGRectMake((wid - w) / 4 - h / 4, h * 3 / 8, h / 4, h * 3 / 8);
    //    }
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 176 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"bt-rightnext.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBackTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:rightButton];
    //    [self.leftButton setFrame:CGRectMake((wid - penWid) / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"bt-leftnext.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(rightForwardTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:leftButton];
    //    [self.rightButton setFrame:CGRectMake((wid - penWid) * 3 / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    [rightSlideView addSubview:rightLightWhiteV];
    
    [self.view insertSubview:rightSlideView belowSubview:self.rightSideView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
