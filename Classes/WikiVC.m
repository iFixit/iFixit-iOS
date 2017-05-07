//
//  WikiVC.m
//  iFixit
//
//  Created by Robert Pascazio on 5/6/17.
//
//

#import "WikiVC.h"

@interface WikiVC ()

@end

@implementation WikiVC

- (void)viewDidLoad {
    [super viewDidLoad];
     NSURL *nsurl = [NSURL URLWithString:self.url];
     NSURLRequest *request = [NSURLRequest requestWithURL:nsurl];
     [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_webView release];
    [super dealloc];
}
@end
