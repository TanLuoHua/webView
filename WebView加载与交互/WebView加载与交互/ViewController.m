//
//  ViewController.m
//  git发贴专业测试
//
//  Created by Mac on 16/4/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "WebModel.h"
#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@interface ViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property WebViewJavascriptBridge* brige;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self downloadZIP];
    [self webHandler];
    // Do any additional setup after loading the view, typically from a nib.
}

/** 下载zip包*/
-(void)downloadZIP{
    NSString* url = @"http://r.jp.yunkangjian.com/media/resources/2016/03/30/lastFigures_N2rPTZc.zip";
//    NSString* url = @"http://dldir1.qq.com/qqfile/qq/QQ8.2/17724/QQ8.2.exe";
    NSString* path = [[self getZIPPath] stringByAppendingPathComponent:@"text.zip"];
    NSLog(@"%@", path);
    [self deleteFileByName:@"text.zip"];
    [WebModel asyncDownloadWithParams:@{@"附加参数":@"测试无"} url:url savedPath:path successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"下载成功");
        [self unArchive];//下载成功后要解压
    } errorBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"下载失败  %@", error.userInfo[@"NSLocalizedDescription"]);
    } progress:^(float progress) {
        NSLog(@"%f", progress);
    }];
}

//解压zip包
-(void)unArchive{
    NSString* fromPath = [[self getZIPPath] stringByAppendingPathComponent:@"text.zip"];
    NSString* toPath = [[self getZIPPath] stringByAppendingPathComponent:@"text"];
    NSLog(@"解压后文件的位置%@", toPath);
    [WebModel unArchiveFromPath:fromPath toPath:toPath progress:^(CGFloat percentDecompressed) {
        NSLog(@"解压进度%f", percentDecompressed);
    }];
//
    [self loadWebView];
}

//通过本地文件加载web页
-(void)loadWebView{
    //引用到.html文件
    NSString* htmlPath = [[self getZIPPath] stringByAppendingFormat:@"/text/lastFigures/lastFigures.html"];
    NSString* path = [htmlPath stringByAppendingFormat:@"?token=%@&get_url=%@", @"我的token", @"http://r.api.xhkhealth.com"];
//    path = @"/Users/mac/Downloads/lastFigures(1)/lastFigures.html";//本地测试路径
    NSLog(@"webPath：%@", path);

    NSURL* url = [NSURL URLWithString:path];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}
#pragma mark -
#pragma mark - webMethod
//webView字体缩小
- (void)zoomIn{
    [self.webView stringByEvaluatingJavaScriptFromString:@"fontZoomB()"];
}
//webView字体放大
- (void)zoomOut{
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"fontZoomA()"];
}
//网页刷新字体缩放
- (void)reloadWebData{
    [self.webView stringByEvaluatingJavaScriptFromString:@"reload()"];
}

///处理网页事件
-(void)webHandler{
    [WebViewJavascriptBridge enableLogging];
    self.brige = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.brige setWebViewDelegate:self];
    //    注册下拉刷新方法  等待JS调用
    [self.brige registerHandler:@"onPullRefreshSuccess" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"下拉刷新执行了 %@", data);
      
    }];
    
    //    注册点击头像方法  等待JS调用
    [self.brige registerHandler:@"gotoMemberInfoViewController" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"点到头像了 人员ID %@", data);
        
    }];
    
    //    调用JS方法 JS需要注册监听
    //    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    //    [self.brige callHandler:@"onPullRefreshSuccess" data:data responseCallback:^(id responseData) {
    //        NSLog(@"onPullRefreshSuccess执行了");
    //    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - publicMethod
- (NSString*)getZIPPath{
    
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* userPath = [docPath stringByAppendingPathComponent:@"webZIP"];
    
    BOOL isDir = NO;
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL existed = [fm fileExistsAtPath:userPath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        [fm createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return userPath;
    
}

//删除ZIP包 需要名字
-(void)deleteFileByName:(NSString*)fileName{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    
    NSString* filePath = [[self getZIPPath] stringByAppendingPathComponent:fileName];
    if ([fm fileExistsAtPath:filePath]) {
        [fm removeItemAtPath:filePath error:&error];
        NSLog(@"文件删除了");
    }
    
}

@end
