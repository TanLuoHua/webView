# webView加载与交互
***
第一次用MarkDown在git上发贴子，用的是Mou这个工具，觉得不错，推荐一下[Mou链接](http://25.io/mou/)，大家可以去参考一下使用！

下面进入正题
***
看一下需求
#####1.通过一个下载链接下载资源包，解压后再去加载
#####2.跟网页有交互，页面如下
![展示页面](pictures/jietu.png =375x689)

***
实现思路

1.下载

2.解压

3.加载

4.交互
***
####下载
我们用的是基于***AFNetworking***封装的下载方法， 用***WebModel***调用
######接口
```objc
//
//  WebModel.h
//  git发贴专业测试
//
//  Created by Mac on 16/4/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface WebModel : NSObject
/**
 *  @author 嘴爷, 2016-04-05 15:04:25
 *
 *  @brief 测试专用，创建一个AFHTTPRequestOperationManager单例(中止下载时候使用)
 *
 *  @return AFHTTPRequestOperationManager单例
 */
+ (AFHTTPRequestOperationManager *)sharedInstance;

/**
 *  @author 嘴爷, 2016-04-05 16:04:53
 *
 *  @brief 根据url停止某个请求
 *
 *  @param url 待停止请求的特征url
 */
+ (void)kickOffOldMe:(NSString *)url;

/**
 *  @author 嘴爷, 2016-04-05 15:04:37
 *
 *  @brief 下载文件
 *
 *  @param paramDic   附加的请求参数
 *  @param requestURL 下载地址
 *  @param savedPath  保存路径
 *  @param success    下载成功的回调
 *  @param failure    下载失败的回调
 *  @param progress   实时下载进度
 */
+ (void)asyncDownloadWithParams:(NSDictionary *)param
                            url:(NSString*)url
                     savedPath:(NSString*)savedPath
               successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock
               errorBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))errorBlock
                      progress:(void (^)(float progress))progress;
@end

```

######实现
```objc
//
//  WebModel.m
//  git发贴专业测试
//
//  Created by Mac on 16/4/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "WebModel.h"
#import <AFHTTPRequestOperationManager.h>
#import <AFURLRequestSerialization.h>

@implementation WebModel

//下载
+(void)asyncDownloadWithParams:(NSDictionary *)param url:(NSString *)url savedPath:(NSString *)savedPath successBlock:(void (^)(AFHTTPRequestOperation *, id))successBlock errorBlock:(void (^)(AFHTTPRequestOperation *, NSError *))errorBlock progress:(void (^)(float))progress{
    
//    下载前停止当前的下载
    [self kickOffOldMe:url];
    
    AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest* request = [serializer requestWithMethod:@"GET" URLString:url parameters:param error:nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    加入到一个全局的队列  为了便于管理
    [[WebModel sharedInstance].operationQueue addOperation:operation];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = totalBytesRead / totalBytesExpectedToRead;
        if (progress) progress(p);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if(errorBlock) errorBlock(operation, error);
    }];
    
    [operation start];
    
}

//线程单例
+(AFHTTPRequestOperationManager *)sharedInstance{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    });
    return sharedInstance;
}

//取消队列中的某个线程(根据url判断)
+ (void)kickOffOldMe:(NSString *)url{
    
    for (AFHTTPRequestOperation *item in [WebModel sharedInstance].operationQueue.operations) {
        if ([item.request.URL.absoluteString containsString:url]) {
            [item cancel];
        }
    }
}

@end
```

####解压
我们用的是基于***AFNetworking***封装的下载方法， 用***WebModel***调用
######接口

