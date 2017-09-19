//
//  ClothDesignViewController.m
//  It'sMe
//
//  Created by Karl Faust on 1/29/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "ClothDesignViewController.h"
#import "ColorBox.h"

#define ITEMTAG 1
#define TEMPLATETAG 2
#define DRAW_PEN 101
#define DRAW_STAMP 102
#define DRAW_COLOR 103
#define DRAW_ERASER 104
#define SAVENAMEINDEX @"name index"

@interface ClothDesignViewController ()<UIScrollViewDelegate>{
    BOOL isTemplateViewShown;//indicating whether the template view is shown or hidden
    BOOL isItemViewShown;//indicating whether the itemView is shown or hidden
    BOOL isSaveSlideViewShown;
    
    BOOL isReadyForDesign;//--------------
    
    //Item View
    UIView *itemView;
    UIScrollView *itemScrollV;
    UIButton *itemNameButton;
    
    NSInteger itemIndex;
    NSInteger penIndex;
    NSInteger colorIndex;
    NSInteger stampIndex;
    
    //------------
    NSMutableArray *penArray;
    NSMutableArray *colorArray;
    NSMutableArray *stampArray;
    
    NSMutableArray *templateNames;
    NSMutableArray *templateImages;
    NSInteger templateCount;
    NSInteger templateIndex;
    NSString *selectedTemplateName;
    
    //Save Slide View
    UIView *saveSlideView;
    
    //Template View
    UIView *templateView;
    UIScrollView *contentScrollV;
    UIButton *templateName;
    
    //drawing image view
    UIView *designView;
    UIImageView *drawImageV;
    UIImageView *bgImageV;
    
    //indicating current State
    NSInteger drawStatus;
    
    //selected color for drawing
    UIColor *drawColor;//-pen Color
    
    CGPoint lastPoint;
    CGFloat penWidth;//-pen width
    
    NSMutableArray *drawImages;//--------saving images step by step
    
    //Studio View
    UIView *studioView;
    UIImageView *backgroundImageView;
    
    //view for showing pen or eraser
    UIView *indicatorV;
    
    //getting the original size of the selected design view
    CGSize originalSize;
}

//ItemView
//@property (weak, nonatomic) IBOutlet UIView *itemView;
//@property (weak, nonatomic) IBOutlet UIView *rigthLightWhiteV;
//@property (weak, nonatomic) IBOutlet UIImageView *leftLightBlueImageV;
//@property (weak, nonatomic) IBOutlet UIImageView *rightLightBlueImageV;
//@property (weak, nonatomic) IBOutlet UIButton *leftButton;
//@property (weak, nonatomic) IBOutlet UIButton *rightButton;
//@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollV;
//@property (weak, nonatomic) IBOutlet UIButton *itemCloseButton;
//@property (weak, nonatomic) IBOutlet UIButton *itemNameButton;

//leftSideView
@property (weak, nonatomic) IBOutlet UIView *leftSideView;
@property (weak, nonatomic) IBOutlet UIView *penView;

//rightSideView
@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet UIView *rightSideView;

//Main View(Studio)
//@property (weak, nonatomic) IBOutlet UIView *studioView;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageV;

@end

@implementation ClothDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isTemplateViewShown = false;
    isItemViewShown = false;
    
    [self initItemsInfo];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SAVENAMEINDEX]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SAVENAMEINDEX];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hiding item View
    [itemView setHidden:true];

    
    //hiding template View
    [templateView setHidden:true];
    
//    [self.itemNameButton.titleLabel setFont:[UIFont systemFontOfSize:self.itemNameButton.frame.size.height / 2]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initItemView];
    [self initTemplateSlideView];
    [self initSaveSlideView];
    
    [self addStudioView];
    
    [self addTemplateItems];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"----");
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


#pragma mark - Custom Event

#pragma mark - Left Event(Tool)

- (IBAction)itemButtonTouchUp:(UIButton *)sender {

    if (sender.tag != 3) {
        [self initItemScroll];
    }
    
    switch (sender.tag) {
        case 1://Pen Size
            drawStatus = DRAW_PEN;
            [itemNameButton setTitle:@"PEN SIZE" forState:UIControlStateNormal];
            [self setPenSizeDataForScroll];
            break;
        case 2://Color
            drawStatus = DRAW_COLOR;
            [itemNameButton setTitle:@"COLOR" forState:UIControlStateNormal];
            [self setColorDataForScroll];
            break;
        case 3://Eraser
            drawStatus = DRAW_ERASER;
//            drawColor = [UIColor clearColor];
            [self hideItemViewWith];
            return;
            break;
        case 4://Stamps
            drawStatus = DRAW_STAMP;
            [itemNameButton setTitle:@"STAMPS" forState:UIControlStateNormal];
            [self setStampDataForScroll];
            break;            
        default:
            break;
    }
    [self showItemView: sender.tag];
}

- (void)itemCloseTouchUp:(UIButton *)sender {
    drawStatus = DRAW_PEN;
    [self hideItemViewWith];
}

- (void)tapForChooseItem: (UITapGestureRecognizer *)sender {
    [sender.view.layer setBorderWidth:1];
    [sender.view.layer setBorderColor:[UIColor blackColor].CGColor];
    
    for (UIView *subV in itemScrollV.subviews) {
        if (subV.tag != sender.view.tag) {
            [subV.layer setBorderWidth:0];
        }
    }
    
    switch (drawStatus) {
        case DRAW_PEN:
            penIndex = sender.view.tag - 1;
            penWidth = (CGFloat)[penArray[penIndex] intValue];
            
            [indicatorV setFrame:CGRectMake(0, 0, penWidth, penWidth)];
            [indicatorV.layer setBorderWidth:1];
            [indicatorV.layer setBorderColor:[UIColor blackColor].CGColor];
            [indicatorV.layer setCornerRadius:penWidth / 2];
            
            break;
        case DRAW_COLOR:
            colorIndex = sender.view.tag;
            drawColor = colorArray[colorIndex];
            break;
        case DRAW_ERASER:
            break;
        case DRAW_STAMP:
            stampIndex = sender.view.tag;
            break;
            
        default:
            break;
    }
}

#pragma mark - Rigth Event(Template)

- (IBAction)exitTouchUp:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)templateTouchUp:(id)sender {
    if (isTemplateViewShown) {
        return;
    }
    
    
    
    [self showTemplateView];
}

- (void)closeTouchUp:(UIButton *)sender {
    [self hideTemplateView];
}

- (void)saveCloseTouchUp:(UIButton *)sender {
    [self hideSaveSlideView];
}

- (void)confirmSaveTouchUp: (UIButton *)sender {
    
    if (isReadyForDesign) {
        return;
    }
    
    //getting design result from design view
    UIGraphicsBeginImageContext(designView.frame.size);
//    UIGraphicsBeginImageContextWithOptions(designView.frame.size, YES, [UIScreen mainScreen].scale);
    CGSize newSize1 = CGSizeMake(designView.frame.size.width, designView.frame.size.height);
    CGSize newSize2 = CGSizeMake(drawImageV.frame.size.width * newSize1.width / originalSize.width, drawImageV.frame.size.height * newSize1.width / originalSize.width);
    [bgImageV.image drawInRect:CGRectMake(0,0,newSize1.width,newSize1.height)];
    
    [drawImageV.image drawInRect:CGRectMake((newSize1.width - newSize2.width) / 2, (newSize1.height - newSize2.height) / 2, newSize2.width, newSize2.height) blendMode:kCGBlendModeNormal alpha:1];
    
//    [designView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //-----------save the designed image
    
    //choose the filename prefix
    NSString *fileNamePrefix;
    if ([selectedTemplateName containsString:CLOTH_PREFIX]) {
        fileNamePrefix = CLOTH_PREFIX;
    }else if ([selectedTemplateName containsString:HAIR_PREFIX]) {
        fileNamePrefix = HAIR_PREFIX;
    }else if ([selectedTemplateName containsString:SHOE_PREFIX]) {
        fileNamePrefix = SHOE_PREFIX;
    }else {
        fileNamePrefix = ACCESSORY_PREFIX;
    }
    
    NSData *pngData = UIImagePNGRepresentation(viewImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:SAVENAMEINDEX] intValue] + 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)index] forKey:SAVENAMEINDEX];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%ld%@", fileNamePrefix, (long)index, EXTENSION]]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file

    //check the image state
//    UIImageView *im = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
//    [im setImage:viewImage];
//    [self.view addSubview:im];
    
    [self hideSaveSlideView];
    isReadyForDesign = YES;
    [designView removeFromSuperview];
}

- (void)confirmTouchUp:(UIButton *)sender {
    [self chooseTemplate];
}

- (IBAction)saveButtonTouchUp:(UIButton *)sender {
    [self showSaveSlideView];
}

- (void)tapTemplateImage: (UITapGestureRecognizer *)sender {
    NSLog(@"tap template twice...");
    
    [self chooseTemplate];
}

- (void)templateBackTouchUp: (UIButton *)sender {
    if (templateIndex < (templateCount - 1)) {
        templateIndex++;

        [contentScrollV setContentOffset:CGPointMake(templateIndex * contentScrollV.frame.size.width, 0) animated:true];
    }
}

- (void)templateForwardTouchUp: (UIButton *)sender {
    if (templateIndex > 0) {
        templateIndex--;
        
        [contentScrollV setContentOffset:CGPointMake(templateIndex * contentScrollV.frame.size.width, 0) animated:true];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (drawStatus == DRAW_PEN || drawStatus == DRAW_ERASER) {
        UITouch *touch = [touches anyObject];
        lastPoint = [touch locationInView:drawImageV];
        
        [designView addSubview:indicatorV];
        indicatorV.center = [touch locationInView:designView];
        [indicatorV setAlpha:1];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (drawStatus == DRAW_PEN || drawStatus == DRAW_ERASER) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:drawImageV];
        indicatorV.center = [touch locationInView:designView];
        
        UIGraphicsBeginImageContext(drawImageV.frame.size);
        [drawImageV.image drawInRect:CGRectMake(0, 0,
                                              drawImageV.frame.size.width,
                                              drawImageV.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penWidth);
        
        if (drawStatus == DRAW_PEN) {
            CGFloat red = 1.0, green = 1.0, blue = 1.0, alpha = 0.0;
            [drawColor getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red,
                                       green, blue, alpha);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        }else{
//            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
            CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        drawImageV.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;

    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (drawStatus == DRAW_PEN || drawStatus == DRAW_ERASER) {
        if (!drawImages || !drawImages.count) {
            drawImages = [[NSMutableArray alloc]init];
        }
        if (drawImageV.image) {
            [drawImages addObject:drawImageV.image];
        }
        
        [indicatorV removeFromSuperview];
        [indicatorV setAlpha:0];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex;
    currentIndex = [self getCycleNumber:(NSInteger)scrollView.contentOffset.x other:(NSInteger)scrollView.frame.size.width];
    if (scrollView.tag == TEMPLATETAG) {
        templateIndex = currentIndex;
    }else{
        itemIndex = currentIndex;
    }
}

#pragma mark - Custom Method

- (void)chooseTemplate {
    if (isReadyForDesign == NO) {//if you already choose the template view, you can add one another after you save origin one.
        return;
    }
    
    isReadyForDesign = NO;
    
    UIImage *templateImage = [UIImage imageNamed:templateImages[templateIndex]];
    selectedTemplateName = templateNames[templateIndex];
    
    CGFloat originHei = templateImage.size.height;
    CGFloat originWid = templateImage.size.width;
    CGFloat hei = self.view.frame.size.height / 4;
    CGFloat wid = templateImage.size.width * hei / templateImage.size.height;
    
    if (originHei >= originWid) {
        hei = self.view.frame.size.height;
        wid = originWid * hei / originHei;
    }else{
        wid = self.view.frame.size.width * 0.7;
        hei = originHei * wid / originWid;
    }
    
    designView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
    originalSize = designView.frame.size;
    [designView.layer setBorderWidth:1];
    [designView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    //    [designView setBackgroundColor:[UIColor blackColor]];
    
    bgImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
    [bgImageV setImage:[UIImage imageNamed:templateImages[templateIndex]]];
    
    drawImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [designView setUserInteractionEnabled:YES];
    
    //    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveDesignView:)];
    //    [designView addGestureRecognizer:panGesture];
    //
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeDesignView:)];
        [designView addGestureRecognizer:pinchGesture];
    //
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDesignView:)];
        [designView addGestureRecognizer:tapGesture];
    
    //    CGPoint touchPoint = [sender locationInView:studioView];
    if (templateView.frame.origin.x >= self.view.frame.size.width) {
        return;
    }
    
    [designView addSubview:bgImageV];
    bgImageV.center = designView.center;
    [designView addSubview:drawImageV];
    drawImageV.center = designView.center;
    
    [studioView addSubview:designView];
    designView.center = studioView.center;
    
    [self hideTemplateView];
}

- (void)addStudioView {
    studioView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundImageView setImage:[UIImage imageNamed:@"BG design.png"]];
    [studioView addSubview:backgroundImageView];
    
    [self.view insertSubview:studioView belowSubview:itemView];
}

- (void)moveDesignView: (UIPanGestureRecognizer *)sender {
    if (sender.numberOfTouches == 1) {
        return;
    }
    [studioView bringSubviewToFront:sender.view];
    CGPoint touchPoint = [sender locationInView:[self view]];
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [sender.view setCenter:touchPoint];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tapDesignView: (UITapGestureRecognizer *)sender {
//    [studioView bringSubviewToFront:sender.view];
    if (drawStatus == DRAW_STAMP) {
        CGPoint touch = [sender locationInView:drawImageV];
        UIImage *originalImage = drawImageV.image;
        UIImageView *stampImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, penWidth, penWidth)];
        [stampImageV setImage:stampArray[stampIndex]];
        UIImage *stampImage = stampImageV.image;
        
        UIGraphicsBeginImageContextWithOptions(drawImageV.frame.size, NO, 0.0f);

        [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
        [stampImage drawInRect:CGRectMake(touch.x - penWidth / 2, touch.y - penWidth / 2, penWidth, penWidth)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        [drawImageV setImage:resultImage];
        UIGraphicsEndImageContext();
    }
}

- (void)resizeDesignView: (UIPinchGestureRecognizer *)sender {
    [studioView bringSubviewToFront:sender.view];
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
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

- (void)addTemplateItems {
    CGFloat wid = contentScrollV.frame.size.width;
    CGFloat hei = contentScrollV.frame.size.height;
    
    [contentScrollV setContentSize:CGSizeMake(wid * templateImages.count, hei)];
    NSInteger i = 0;
    
    templateCount = templateImages.count;
    
    for (NSString *itemName in templateImages) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i * wid, hei / 4, wid, hei / 2)];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [imgV setImage:[UIImage imageNamed:itemName]];
        
        //adding gestures
        [imgV setTag:i];
        [imgV setUserInteractionEnabled:YES];
        //        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressLeftImage:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTemplateImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        
        [imgV addGestureRecognizer:tapGesture];
        
        [contentScrollV addSubview:imgV];
        
        i++;
    }
}

- (void)initItemsInfo {
    
    indicatorV = [[UIView alloc] init];
    
    isReadyForDesign = YES;
    
    //setting initial pen color and pen width
    drawColor = [UIColor blackColor];
    penWidth = -1;
    drawStatus = -1;
    penIndex = -1;
    colorIndex = -1;
    stampIndex = -1;

    penArray = [[NSMutableArray alloc] init];
    for (CGFloat i = 1; i <= 70; i += 3) {
        [penArray addObject:[NSString stringWithFormat:@"%f", i]];
    }
    
    //set the color data for array
    [self initColorBox];
    
    //get the resource path
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //set the stamp data for array
    NSString * itemsPath = [resourcePath stringByAppendingPathComponent:@"/stamp/"];
    NSArray* items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                         error:NULL];
    stampArray = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        NSString *filePath = [itemsPath stringByAppendingPathComponent:fileName];
        [stampArray addObject:[UIImage imageNamed:filePath]];
    }];
//    stampArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"stamp-flower.png"], [UIImage imageNamed:@"stamp-foot.png"], [UIImage imageNamed:@"stamp-heart.png"], [UIImage imageNamed:@"stamp-smile.png"], [UIImage imageNamed:@"stamp-star.png"], nil];
    
    //getting template info from resource
    templateImages = [[NSMutableArray alloc] init];
    templateNames = [[NSMutableArray alloc] init];
    
    //get the background images path
    itemsPath = [resourcePath stringByAppendingPathComponent:@"/template/"];
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemsPath
                                                                         error:NULL];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        [templateImages addObject:[itemsPath stringByAppendingPathComponent:fileName]];
        [templateNames addObject:[(NSString *)obj stringByDeletingPathExtension]];
    }];

}

- (void)initColorBox {
    colorArray = [NSMutableArray arrayWithObjects:[UIColor colorWithRed:255.0f / 255.0f green:204.0f / 255.0f blue:255.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:243.0f / 255.0f green:124.0f / 255.0f blue:194.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:102.0f / 255.0f blue:204.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:51.0f / 255.0f blue:204.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:153.0f / 255.0f green:0.0f / 255.0f blue:153.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:0.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:153.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:255.0f / 255.0f green:51.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:0.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:153.0f / 255.0f green:0.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:0.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:51.0f / 255.0f green:0.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:153.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:51.0f / 255.0f green:102.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:0.0f / 255.0f green:51.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:232.0f / 255.0f green:230.0f / 255.0f blue:19.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:204.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:153.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:51.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:153.0f / 255.0f blue:204.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:0.0f / 255.0f green:51.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:102.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:0.0f / 255.0f green:204.0f / 255.0f blue:204.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:0.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:204.0f / 255.0f green:102.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                  , [UIColor colorWithRed:255.0f / 255.0f green:102.0f / 255.0f blue:0.0f / 255.0f alpha:1], nil];
}

- (void)hideTemplateView {
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [templateView setFrame:CGRectMake( templateView.frame.size.width * 2, 0, templateView.frame.size.width, templateView.frame.size.height)];
    } completion:^(BOOL finished) {
//        if (isCloseButton) {//if current button is close, hide leftsideview
            [templateView setHidden:true];
            isTemplateViewShown = false;
//        }else{//if not, show again
//            [self showLeftSlideView];
//        }
    }];
}

- (void)showTemplateView {
    [templateView setHidden:false];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [templateView setFrame:CGRectMake( templateView.frame.size.width, 0, templateView.frame.size.width, templateView.frame.size.height)];
    } completion:^(BOOL finished) {
        isTemplateViewShown = true;
    }];
}

- (void)hideSaveSlideView {
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [saveSlideView setFrame:CGRectMake( saveSlideView.frame.size.width * 2, saveSlideView.frame.origin.y, saveSlideView.frame.size.width, saveSlideView.frame.size.height)];
    } completion:^(BOOL finished) {

        [saveSlideView setHidden:true];
        isSaveSlideViewShown = false;

    }];
}

- (void)showSaveSlideView {
    [saveSlideView setHidden:false];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [saveSlideView setFrame:CGRectMake( saveSlideView.frame.size.width, saveSlideView.frame.origin.y, saveSlideView.frame.size.width, saveSlideView.frame.size.height)];
    } completion:^(BOOL finished) {
        isSaveSlideViewShown = true;
    }];
}


- (void)hideItemViewWith {
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [itemView setFrame:CGRectMake( - itemView.frame.size.width, itemView.frame.origin.y, itemView.frame.size.width, itemView.frame.size.height)];
        
//        [self.itemView setFrame:CGRectMake(self.itemView.frame.size.width, self.penView.frame.origin.y + self.penView.frame.size.height * index, self.itemView.frame.size.width, self.itemView.frame.size.height)];
    } completion:^(BOOL finished) {
        [itemView setHidden:true];
    }];
}

- (void)showItemView: (NSInteger)index {
    [itemView setHidden:false];
    [UIView animateWithDuration:TIMERINTERVAL delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [itemView setFrame:CGRectMake(0, self.penView.frame.origin.y + self.penView.frame.size.height * (index - 1), itemView.frame.size.width, itemView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
}

//set the pen size data for scroll view
- (void)setPenSizeDataForScroll {
    CGFloat hei = itemScrollV.frame.size.height;
    int PEN_COUNT = 24;
    
    [itemScrollV setContentSize:CGSizeMake((hei + 10) * PEN_COUNT, hei)];
    for (int i = 1; i <= PEN_COUNT; i++) {
        UIView *penV = [[UIView alloc] initWithFrame:CGRectMake((hei + 10) * (i - 1), 0, hei, hei)];
        CGFloat w = (CGFloat)i / (CGFloat)PEN_COUNT * hei;
        
        UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake((hei - w) / 2, (hei - w) / 2, w, w)];
        [colorV setBackgroundColor:[UIColor redColor]];
        [colorV.layer setCornerRadius:w / 2];
        [penV addSubview:colorV];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForChooseItem:)];
        [penV addGestureRecognizer:tapGesture];
        [penV setTag:i];
        
        [itemScrollV addSubview:penV];
        
        if (i == penIndex && penIndex != -1) {
            [penV.layer setBorderWidth:1];
            [penV.layer setBorderColor:[UIColor blackColor].CGColor];
        }
    }
}

//set the color data for scroll view
- (void)setColorDataForScroll {
    CGFloat hei = itemScrollV.frame.size.height;
    
    [itemScrollV setContentSize:CGSizeMake((hei + 10) * colorArray.count, hei)];
    for (int i = 0; i < colorArray.count; i++) {
        UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake((hei + 10) * i, 0, hei, hei)];
        [colorV setBackgroundColor:[UIColor clearColor]];
        UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(5, 5, hei - 10, hei - 10)];
        [contentV setBackgroundColor:(UIColor *)colorArray[i]];
        [contentV.layer setCornerRadius:hei / 5];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForChooseItem:)];
        [colorV addGestureRecognizer:tapGesture];
        [colorV setTag:i];
        [colorV addSubview:contentV];
        
        [itemScrollV addSubview:colorV];
        
        if (i == colorIndex && colorIndex != -1) {
            [colorV.layer setBorderWidth:1];
            [colorV.layer setBorderColor:[UIColor blackColor].CGColor];
        }
    }
}

//set the stamp data for scroll view
- (void)setStampDataForScroll {
    CGFloat hei = itemScrollV.frame.size.height;
    NSUInteger STAMP_COUNT = stampArray.count;
    
    [itemScrollV setContentSize:CGSizeMake((hei + 10) * STAMP_COUNT, hei)];
    for (int i = 0; i < STAMP_COUNT; i++) {
        UIView *stampV = [[UIView alloc] initWithFrame:CGRectMake((hei + 10) * i, 0, hei, hei)];
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, hei, hei)];
        [imageV setImage:(UIImage *)stampArray[i]];
        
        [stampV addSubview:imageV];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForChooseItem:)];
        [stampV addGestureRecognizer:tapGesture];
        [stampV setTag:i];

        [itemScrollV addSubview:stampV];
        
        if (i == stampIndex && stampIndex != -1) {
            [stampV.layer setBorderWidth:1];
            [stampV.layer setBorderColor:[UIColor blackColor].CGColor];
        }
    }
}

- (void)initItemScroll {
    for (UIView *subV in itemScrollV.subviews) {
        [subV removeFromSuperview];
    }
}


- (void)initItemView {
    CGFloat wid = self.view.frame.size.width / 2;
    CGFloat penWid = self.penView.frame.size.width;
    CGFloat penHei = self.penView.frame.size.height;
    
    itemView = [[UIView alloc] initWithFrame:CGRectMake( - wid, self.penView.frame.origin.y, wid, penHei)];
    [itemView setBackgroundColor:[UIColor clearColor]];
//    [self.itemView setFrame:CGRectMake( - wid, self.penView.frame.origin.y, wid, penHei)];//itemView
    
    UIImageView *leftLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, penWid, penHei)];
    [leftLightBlueImageV setImage:[UIImage imageNamed:@"left-light-blue.png"]];
    [leftLightBlueImageV setBackgroundColor:[UIColor clearColor]];
    [itemView addSubview:leftLightBlueImageV];
//    [self.leftLightBlueImageV setFrame:CGRectMake(0, 0, penWid, penHei)];
    //-----------------
    UIView *rightLightWhiteV = [[UIView alloc] initWithFrame:CGRectMake(penWid, 0, wid - penWid, penHei)];
    [rightLightWhiteV setBackgroundColor:[UIColor clearColor]];
//    [self.rigthLightWhiteV setFrame:CGRectMake(penWid, 0, wid - penWid, penHei)];
    
    UIImageView *rightLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid - penWid, penHei)];
    [rightLightBlueImageV setImage:[UIImage imageNamed:@"left-light-white.png"]];
    [rightLightWhiteV addSubview:rightLightBlueImageV];
//    [self.rightLightBlueImageV setFrame:CGRectMake(0, 0, wid - penWid, penHei)];
    
    UIButton *itemCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    [itemCloseButton setBackgroundImage:[UIImage imageNamed:@"bt-leftclose.png"] forState:UIControlStateNormal];
    [itemCloseButton addTarget:self action:@selector(itemCloseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:itemCloseButton];
//    [self.itemCloseButton setFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    
    itemNameButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - penWid) / 4, 0, (wid - penWid) / 2, penHei * 3 / 8)];
    [itemNameButton setBackgroundImage:[UIImage imageNamed:@"left-label.png"] forState:UIControlStateNormal];
    itemNameButton.userInteractionEnabled = NO;
    [itemNameButton.titleLabel setFont:[UIFont systemFontOfSize:itemNameButton.frame.size.height / 2]];
    [rightLightWhiteV addSubview:itemNameButton];
//    [self.itemNameButton setFrame:CGRectMake((wid - penWid) / 4, 0, penWid / 2, penHei * 3 / 8)];
    
    itemScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake((wid - penWid) / 4, penHei * 3 / 8, (wid - penWid) / 2, penHei * 3 / 8)];
    [itemScrollV setShowsHorizontalScrollIndicator:false];
    [itemScrollV setShowsVerticalScrollIndicator:false];
    [itemScrollV setScrollEnabled:true];
    [itemScrollV setTag:ITEMTAG];
    itemScrollV.delegate = self;
    [rightLightWhiteV addSubview:itemScrollV];
//    [self.itemScrollV setFrame:CGRectMake((wid - penWid) / 4, penHei * 3 / 8, penWid / 2, penHei * 3 / 8)];

    CGRect rightRect;
    CGRect leftRect;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rightRect = CGRectMake((wid - penWid) * 3 / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8);
        leftRect = CGRectMake((wid - penWid) / 4 , penHei * 3 / 8, penHei / 4, penHei * 3 / 8);
    }else{
        rightRect = CGRectMake((wid - penWid) * 3 / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8);
        leftRect = CGRectMake((wid - penWid) / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8);
    }
    UIButton *leftButton = [[UIButton alloc] initWithFrame:leftRect];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"bt-leftnext.png"] forState:UIControlStateNormal];
    [rightLightWhiteV addSubview:leftButton];
//    [self.leftButton setFrame:CGRectMake((wid - penWid) / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];

    UIButton *rightButton = [[UIButton alloc] initWithFrame:rightRect];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"bt-rightnext.png"] forState:UIControlStateNormal];
    [rightLightWhiteV addSubview:rightButton];
//    [self.rightButton setFrame:CGRectMake((wid - penWid) * 3 / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    [itemView addSubview:rightLightWhiteV];

    [self.view insertSubview:itemView belowSubview:self.leftSideView];
}

- (void)initSaveSlideView {
    CGFloat wid = self.view.frame.size.width / 2;
    CGFloat saveWid = self.saveView.frame.size.width;
    CGFloat saveHei = self.saveView.frame.size.height;
    
    saveSlideView = [[UIView alloc] initWithFrame:CGRectMake( wid * 2, self.saveView.frame.origin.y, wid, saveHei)];
    [saveSlideView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *leftLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(wid - saveWid, 0, saveWid, saveHei)];
    [leftLightBlueImageV setImage:[UIImage imageNamed:@"right-light-blue.png"]];
    [leftLightBlueImageV setBackgroundColor:[UIColor clearColor]];
    [saveSlideView addSubview:leftLightBlueImageV];

    
    //-----------------
    UIView *rightLightWhiteV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid - saveWid, saveHei)];
    [rightLightWhiteV setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *rightLightWhiteImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wid - saveWid, saveHei)];
    [rightLightWhiteImageV setImage:[UIImage imageNamed:@"right-light-white.png"]];
    [rightLightWhiteV addSubview:rightLightWhiteImageV];
    //    [self.rightLightBlueImageV setFrame:CGRectMake(0, 0, wid - penWid, penHei)];
    
    UIButton *saveCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, saveHei / 4, saveHei / 2, saveHei / 2)];
    [saveCloseButton setBackgroundImage:[UIImage imageNamed:@"bt-rightclose.png"] forState:UIControlStateNormal];
    [saveCloseButton addTarget:self action:@selector(saveCloseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:saveCloseButton];
    //    [self.itemCloseButton setFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    
    UIButton *saveNameButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - saveWid) / 4, 0, (wid - saveWid) / 2, saveHei * 3 / 8)];
    [saveNameButton setBackgroundImage:[UIImage imageNamed:@"right-label.png"] forState:UIControlStateNormal];
    saveNameButton.userInteractionEnabled = NO;
    [saveNameButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveNameButton.titleLabel setFont:[UIFont systemFontOfSize:saveNameButton.frame.size.height / 2]];
    [rightLightWhiteV addSubview:saveNameButton];
    
    UIButton *confirmBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - saveWid - saveHei * 2 / 5 - saveHei / 6, saveHei / 4 + saveHei / 12, saveHei * 2 / 5, saveHei * 2 / 5)];
    [confirmBt setBackgroundImage:[UIImage imageNamed:@"bt-save.png"] forState:UIControlStateNormal];
    [confirmBt addTarget:self action:@selector(confirmSaveTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:confirmBt];
    
    [saveSlideView addSubview:rightLightWhiteV];
    
    [self.view insertSubview:saveSlideView belowSubview:self.rightSideView];
}

- (void)initTemplateSlideView {
    CGFloat wid = self.view.frame.size.width / 2;
    CGFloat w = self.rightSideView.frame.size.width;
    CGFloat h = self.rightSideView.frame.size.height;
    
    templateView = [[UIView alloc] initWithFrame:CGRectMake(wid * 2, 0, wid, h)];
    [templateView setBackgroundColor:[UIColor clearColor]];
    //    [self.itemView setFrame:CGRectMake( - wid, self.penView.frame.origin.y, wid, penHei)];//itemView
    
    UIImageView *rightLightBlueImageV = [[UIImageView alloc] initWithFrame:CGRectMake(wid - w, 0, w, h)];
    [rightLightBlueImageV setImage:[UIImage imageNamed:@"right-panel-blue.png"]];
    [rightLightBlueImageV setBackgroundColor:[UIColor clearColor]];
    [templateView addSubview:rightLightBlueImageV];
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
    [closeButton addTarget:self action:@selector(closeTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:closeButton];
    //    [self.itemCloseButton setFrame:CGRectMake(wid - penWid - penHei / 2, penHei / 4, penHei / 2, penHei / 2)];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (h - (wid - w) * 150 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"bt_confirm.png"] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:confirmButton];
    
    templateName = [[UIButton alloc] initWithFrame:CGRectMake((wid - w - (wid - w) * 192 / 276) / 2, 8, (wid - w) * 192 / 276, h * 49 / 414)];
    [templateName setBackgroundImage:[UIImage imageNamed:@"right-label.png"] forState:UIControlStateNormal];
    templateName.userInteractionEnabled = NO;
    [templateName.titleLabel setFont:[UIFont systemFontOfSize:templateName.frame.size.height / 3]];
    [templateName setTitle:@"Template" forState:UIControlStateNormal];
    [rightLightWhiteV addSubview:templateName];
    //    [self.itemNameButton setFrame:CGRectMake((wid - penWid) / 4, 0, penWid / 2, penHei * 3 / 8)];
    
    contentScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, h * 65 / 414, (wid - w) * 176 / 276, h * 284 / 414)];
    [contentScrollV setShowsHorizontalScrollIndicator:false];
    [contentScrollV setShowsVerticalScrollIndicator:false];
    [contentScrollV setPagingEnabled:true];
    [contentScrollV setTag:TEMPLATETAG];
    contentScrollV.delegate = self;
    //    [rightScrollV setBackgroundColor:[UIColor blackColor]];
    
    [rightLightWhiteV addSubview:contentScrollV];
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
    [rightButton addTarget:self action:@selector(templateBackTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:rightButton];
    //    [self.leftButton setFrame:CGRectMake((wid - penWid) / 4 - penHei / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake((wid - w) * 50 / 276, (h - (wid - w) * 50 / 276) / 2, (wid - w) * 50 / 276, (wid - w) * 50 / 276)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"bt-leftnext.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(templateForwardTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [rightLightWhiteV addSubview:leftButton];
    //    [self.rightButton setFrame:CGRectMake((wid - penWid) * 3 / 4, penHei * 3 / 8, penHei / 4, penHei * 3 / 8)];
    [templateView addSubview:rightLightWhiteV];
    
    [self.view insertSubview:templateView belowSubview:self.rightSideView];

}

//


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
