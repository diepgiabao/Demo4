//
//  BookmarkEditViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkDirectoryEditViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkEditTextFieldTableViewCell.h"

@interface BookmarkDirectoryEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, copy) NSString *sectionName;

@end

@implementation BookmarkDirectoryEditViewController

//Add directory
- (instancetype)initWithDataManager:(BookmarkDataManager *)dataManager completion:(BookmarkEditCompletion)completion{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.dataManager = dataManager;
        self.completion = completion;
        _operationKind = BookmarkOperationKindSectionAdd;
    }
    return self;
}

//Edit directory name
- (instancetype)initWithDataManager:(BookmarkDataManager *)dataManager sectionName:(NSString *)sectionName sectionIndex:(NSIndexPath *)indexPath completion:(BookmarkEditCompletion)completion{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.dataManager = dataManager;
        self.completion = completion;
        _operationKind = BookmarkOperationKindSectionEdit;
        _sectionName = sectionName;
        self.indexPath= indexPath;
    }
    return self;
}

- (void)initUI{
    [super initUI];
    self.title = @"Folder";
}

#pragma mark - Handle NavigationItem Clicked

- (void)handleDoneItemClicked{
    BookmarkEditTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *name = cell.textField.text;
    if (!name || [name isEqualToString:@""]) {
        [self.view showHUDWithMessage:@"The folder name cannot be empty"];
        return;
    }
    
    WEAK_REF(self)
    BookmarkDataCompletion completion = ^(BOOL success){
        STRONG_REF(self_)
        if (self__ && success) {
            [self__ exit];
            if (self__.completion) {
                self__.completion();
            }
        }
        else if (self__){
            [self__.view showHUDWithMessage:@"Folder name cannot be the same"];
        }
    };
    
    if (self.operationKind == BookmarkOperationKindSectionEdit) {
        [self.dataManager editBookmarkDirectoryWithName:name sectionIndex:self.indexPath.section completion:completion];
    }
    else{
        [self.dataManager addBookmarkDirectoryWithName:name completion:completion];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookmarkEditTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkEditTextFieldCellIdentifier];
    if (self.operationKind == BookmarkOperationKindSectionEdit) {
        [cell.textField setText:self.sectionName];
    }
    [cell.textField becomeFirstResponder];
    cell.textField.delegate = self;
    
    return cell;
}

@end
