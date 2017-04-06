//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "GKImageCropView.h"

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;
@property (nonatomic, strong) UISlider *exposureSlider;
@property (nonatomic) Float32  lastExpVal;

@property UIImageOrientation  sourceImageOrientation;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton, resizeableCropArea;
@synthesize lastExpVal;
    
#pragma mark -
#pragma Private Methods


- (void)_actionCancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_actionUse{
    _croppedImage = [self.imageCropView croppedImage];
    [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
}

- (void)handleFilterToggle{
    
    [imageCropView returnImageToOriginal];
    
}

- (void)_setupFilterToggle{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 60);
    [button addTarget:self action:@selector(handleFilterToggle) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Un-filter" forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    button.titleLabel.textColor = [UIColor blackColor];
    button.titleLabel.sizeToFit;
    button.translatesAutoresizingMaskIntoConstraints = false;
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 15;
    
    NSLayoutConstraint *buttonAndSlider = [NSLayoutConstraint
                                          constraintWithItem:button
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.exposureSlider
                                          attribute:NSLayoutAttributeTop
                                          multiplier:1.0
                                          constant:-20];
    
    NSLayoutConstraint *buttonAndWall = [NSLayoutConstraint
                                        constraintWithItem:button
                                        attribute:NSLayoutAttributeRight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                        attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                        constant:-40];
    
    NSLayoutConstraint *buttonWidth = [NSLayoutConstraint
                                      constraintWithItem:button
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0
                                      constant:100];
    
    NSLayoutConstraint *buttonHeight = [NSLayoutConstraint
                                       constraintWithItem:button
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:nil
                                       attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1.0
                                       constant:60];
    
   // NSArray *customConstraints = [[NSArray alloc] initWithObjects:buttonHeight,buttonWidth,buttonAndWall,buttonAndSlider, nil];
    
    [self.view addConstraint:buttonAndSlider];
    [self.view addConstraint:buttonAndWall];
    [self.view addConstraint:buttonWidth];
    [self.view addConstraint:buttonHeight];
    
    
    
   // [self.view addConstraints:customConstraints];
    [self.view layoutSubviews];
}

- (void)_setupFilterLabel{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    label.text = @"Exposure";
    [self.view addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint *labelAndSlider = [NSLayoutConstraint
                                           constraintWithItem:label
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.exposureSlider
                                           attribute:NSLayoutAttributeTop
                                           multiplier:1.0
                                           constant:-20];
    
    NSLayoutConstraint *labelAndWall = [NSLayoutConstraint
                                          constraintWithItem:label
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeLeft
                                          multiplier:1.0
                                          constant:40];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint
                                        constraintWithItem:label
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:100];
    
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint
                                      constraintWithItem:label
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0
                                      constant:60];
    
    //NSArray *customConstraints = [[NSArray alloc] initWithObjects:labelHeight,labelWidth,labelAndWall,labelAndSlider, nil];
    [self.view addConstraint:labelAndSlider];
    [self.view addConstraint:labelAndWall];
    [self.view addConstraint:labelWidth];
    [self.view addConstraint: labelHeight];
    //[self.view addConstraints:customConstraints];
    [self.view layoutSubviews];
}

- (void)_setupExposureSlider{
    
    self.exposureSlider = [[UISlider alloc] init];
    NSDictionary *views = _NSDictionaryOfVariableBindings(@"subview", _exposureSlider);
    [self.view addSubview:self.exposureSlider];
    self.exposureSlider.translatesAutoresizingMaskIntoConstraints = false;

   NSLayoutConstraint *fiftyFromBottom = [NSLayoutConstraint
                                                        constraintWithItem:self.exposureSlider
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                        attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                        constant:-50];
    
    [self.view addConstraint:fiftyFromBottom];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[subview]-50-|" options: 0 metrics:nil views:views]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]-100-|" options: 0 metrics:nil views:views]];
                
    
    [self.view layoutSubviews];
    [self.exposureSlider addTarget:self action:@selector(didSlide) forControlEvents:UIControlEventValueChanged];
    [self.exposureSlider setMinimumValue:-3.0];
    [self.exposureSlider setMaximumValue:7.0];
   
    [imageCropView filterAndDisplay:_exposureSlider.value];
}

- (void)didSlide{
    printf("before did slide: %f\n", CACurrentMediaTime());
    [imageCropView filterAndDisplay:_exposureSlider.value];
    printf("after did slide: %f\n", CACurrentMediaTime());
     }
     
- (void)_setupNavigationBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(_actionCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"")
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(_actionUse)];
}


- (void)_setupCropView{
    
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    
    //
    [self.imageCropView setImageToCrop:sourceImage];
    //
    
    [self.imageCropView setResizableCropArea:self.resizeableCropArea];
    [self.imageCropView setCropSize:cropSize];
    [self.view addSubview:self.imageCropView];
    [self.imageCropView setBackgroundColor:[UIColor whiteColor]];
}

- (void)_setupCancelButton{
	
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
        [[self.cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
        [self.cancelButton setFrame:CGRectMake(0, 0, 58, 30)];
        [self.cancelButton setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
        [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
        [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
		
        [[self.cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
        [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        [self.cancelButton setFrame:CGRectMake(0, 0, 50, 30)];
        [self.cancelButton setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
        [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_setupUseButton{
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
        [[self.useButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        [[self.useButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
        [self.useButton setFrame:CGRectMake(0, 0, 58, 30)];
        [self.useButton setTitle:NSLocalizedString(@"Crop",@"") forState:UIControlStateNormal];
        [self.useButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
        [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
        [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
		
        [[self.useButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
        [[self.useButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
        [self.useButton setFrame:CGRectMake(0, 0, 50, 30)];
        [self.useButton setTitle:NSLocalizedString(@"Crop",@"") forState:UIControlStateNormal];
        [self.useButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
        [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UIImage *)_toolbarBackgroundImage{
    CGFloat components[] = {
        1., 1., 1., 1.,
        123./255., 125/255., 132./255., 1.
    };
	
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 54), YES, 0.0);
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
	
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, 54), kCGImageAlphaNoneSkipFirst);
	
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
	
    return viewImage;
}

- (void)_setupToolbar{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        
		
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.toolbar.translucent = YES;
            self.toolbar.barStyle = UIBarStyleBlackOpaque;
        } else {
            [self.toolbar setBackgroundImage:[self _toolbarBackgroundImage] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }

        [self.view addSubview:self.toolbar];
        
        [self _setupCancelButton];
        [self _setupUseButton];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectZero];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            info.text = @"";
        } else {
            info.text = NSLocalizedString(@"Move and Scale", @"");
        }
        
        info.textColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.173 alpha:1];
        info.backgroundColor = [UIColor clearColor];
        info.shadowColor = [UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1];
        info.shadowOffset = CGSizeMake(0, 1);
        info.font = [UIFont boldSystemFontOfSize:18];
        [info sizeToFit];
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView:info];
        UIBarButtonItem *use = [[UIBarButtonItem alloc] initWithCustomView:self.useButton];
        
        [self.toolbar setItems:[NSArray arrayWithObjects:cancel, flex, lbl, flex, use, nil]];

    }
}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Choose Photo", @"");

    [self _setupNavigationBar];
    [self _setupCropView];
    [self _setupToolbar];
    [self _setupExposureSlider];
    [self _setupFilterToggle];
    [self _setupFilterLabel];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.imageCropView.frame = self.view.bounds;
    self.toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 54, 320, 54);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
