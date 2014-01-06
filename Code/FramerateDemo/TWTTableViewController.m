//
//  TWTTableViewController.m
//  FramerateDemo
//
//  Created by Kevin Conner on 1/6/14.
//  Copyright (c) 2014 Two Toasters. All rights reserved.
//

#import "TWTTableViewController.h"

static NSString * const kCellIdentifier = @"CellIdentifier";

@interface TWTTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *tableContainer; // right 50%
@property (nonatomic, strong) UIView *snapshotContainer; // right 50%

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) UITableView *tableView; // added once to table container

@property (nonatomic, assign) NSInteger frequency;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *snapshotView; // created and added to snapshot container when timer fires

@end

@implementation TWTTableViewController

#pragma mark - Helpers

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)resetTimer
{
    [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:1.0 / self.frequency target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    self.title = [NSString stringWithFormat:@"60fps | %dfps", self.frequency];
}

- (void)timerFired:(NSTimer *)timer
{
    [self.snapshotView removeFromSuperview];
    self.snapshotView = [self.tableContainer snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.frame = self.snapshotContainer.bounds;
    [self.snapshotContainer addSubview:self.snapshotView];
}

- (void)stepperValueChanged:(id)sender
{
    UIStepper *stepper = sender;
    self.frequency = stepper.value;
    [self resetTimer];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self resetTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self stopTimer];
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
