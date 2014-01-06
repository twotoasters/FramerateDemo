//
//  TWTTableViewController.m
//  FramerateDemo
//
//  Created by Kevin Conner on 1/6/14.
//  Copyright (c) 2014 Two Toasters. All rights reserved.
//

#import "TWTTableViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kCellIdentifier = @"CellIdentifier";

@interface TWTTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) NSDate *nextDrawDate;
@property (nonatomic, assign) NSInteger frequency;

@property (nonatomic, strong) UIView *tableContainer; // right 50%
@property (nonatomic, strong) UIView *snapshotContainer; // right 50%
@property (nonatomic, strong) UITableView *tableView; // added once to table container
@property (nonatomic, strong) UIView *snapshotView; // created and added to snapshot container when timer fires

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation TWTTableViewController

#pragma mark - Helpers

- (void)displayLinkFired
{
    // Seek to the next draw date. Draw if we actually closed over one of those intervals.
    BOOL draw = NO;
    NSTimeInterval period = 1.0 / self.frequency;
    while ([self.nextDrawDate compare:[NSDate date]] == NSOrderedAscending) {
        self.nextDrawDate = [self.nextDrawDate dateByAddingTimeInterval:period];
        draw = YES;
    }

    if (draw) {
        [self.snapshotView removeFromSuperview];
        self.snapshotView = [self.tableContainer snapshotViewAfterScreenUpdates:NO];
        self.snapshotView.frame = self.snapshotContainer.bounds;
        [self.snapshotContainer addSubview:self.snapshotView];
    }
}

- (void)stopDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;

    self.nextDrawDate = nil;
}

- (void)startDisplayLink
{
    self.nextDrawDate = [NSDate date];

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFired)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stepperValueChanged:(id)sender
{
    UIStepper *stepper = sender;
    self.frequency = stepper.value;
    [self updateTitle];
}

- (void)updateTitle
{
    self.title = [NSString stringWithFormat:@"60fps | %dfps", (int) self.frequency];
}

#pragma mark - Init/dealloc

- (id)init
{
    self = [super init];
    if (self) {
        _frequency = 50;

        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"CountriesList" withExtension:@"plist"];
        _items = [[[NSDictionary dictionaryWithContentsOfURL:fileURL] allValues] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableContainer = [UIView new];
    self.tableContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableContainer];

    self.snapshotContainer = [UIView new];
    self.snapshotContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.snapshotContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.snapshotContainer];

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableContainer, _snapshotContainer);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_tableContainer][_snapshotContainer]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableContainer]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_snapshotContainer]|" options:0 metrics:0 views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                             toItem:self.snapshotContainer attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];

    self.tableView = [[UITableView alloc] initWithFrame:self.tableContainer.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableContainer addSubview:self.tableView];

    UIStepper *stepper = [UIStepper new];
    stepper.minimumValue = 1;
    stepper.maximumValue = 60;
    stepper.value = self.frequency;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:stepper];

    [self updateTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self startDisplayLink];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self stopDisplayLink];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = self.items[indexPath.row];
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor whiteColor] : [UIColor colorWithWhite:0.9f alpha:1.0f];

    return cell;
}

@end
