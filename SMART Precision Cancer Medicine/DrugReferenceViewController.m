//
//  DrugReferenceViewController.m
//  SMART Precision Cancer Medicine
//
//  Created by Daniel Carbone on 5/1/15.
//  Copyright (c) 2015 RIC. All rights reserved.
//

#import "DrugReferenceViewController.h"

#import "DrugReferenceLinkView.h"
#import "DrugDataHelper.h"

@interface DrugReferenceViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) NSString *disease;
@property (nonatomic, strong) NSString *gene;

@property (nonatomic, strong) UINavigationController *webViewNavController;
@property (nonatomic, strong) UIViewController *webViewController;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *currentURLString;

- (void)closeWebView:(id)sender;

@end

static DrugDataHelper *drugDataHelper;

@implementation DrugReferenceViewController

- (instancetype)initWithDisease:(NSString *)disease andGene:(NSString *)gene
{
    self = [super init];
    if (self) {
        if (!drugDataHelper) {
            drugDataHelper = [[DrugDataHelper alloc] init];
        }
        
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        _disease = disease;
        _gene = gene;
        
        
        _webViewController = [[UIViewController alloc] init];
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webViewController.view = _webView;
        _webViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                                style:UIBarButtonItemStylePlain
                                                                                               target:self
                                                                                               action:@selector(closeWebView:)];
        _webViewNavController = [[UINavigationController alloc] initWithRootViewController:_webViewController];
    }
    return self;
}

- (void)loadView
{
    self.view = [[DrugReferenceLinkView alloc] initWithDisease:_disease andGene:_gene];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    DrugReferenceLinkView *view = (DrugReferenceLinkView *)self.view;
    
    [[view diseaseReferenceButton] addTarget:self
                                      action:@selector(openDiseaseDrugReference:)
                            forControlEvents:UIControlEventTouchUpInside];
    [[view diseaseImage] addTarget:self
                            action:@selector(openDiseaseDrugReference:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [[view geneReferenceButton] addTarget:self
                                   action:@selector(openGeneDrugReference:)
                         forControlEvents:UIControlEventTouchUpInside];
    [[view geneImage] addTarget:self
                         action:@selector(openGeneDrugReference:)
               forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Link opening buttons

- (void)openDiseaseDrugReference:(id)sender
{
    NSURL *url;
    if ((url = [drugDataHelper drugReferenceURLForDisease:_disease])) {
        
        [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        
        _webViewController.title = [NSString stringWithFormat:@"%@ Drug Reference", _disease];
        _currentURLString = [url absoluteString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self presentViewController:_webViewNavController animated:YES completion:nil];
    }
}

- (void)openGeneDrugReference:(id)sender
{
    NSURL *url;
    if ((url = [drugDataHelper drugReferenceURLForGene:_gene])) {
        _webViewController.title = [NSString stringWithFormat:@"%@ Inhibitor Drug Reference", _gene];
        _currentURLString = [url absoluteString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self presentViewController:_webViewNavController animated:YES completion:nil];
    }
}

- (void)closeWebView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
    
//    NSString *newURLString = [request.URL absoluteString];
//    if ([newURLString isEqualToString:_currentURLString]) {
//        return YES;
//    }
//    
//    [[UIApplication sharedApplication] openURL:request.URL];
//    
//    return NO;
}

@end
