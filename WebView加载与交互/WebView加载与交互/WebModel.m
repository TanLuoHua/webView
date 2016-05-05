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
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        if (progress) progress(p);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if(errorBlock) errorBlock(operation, error);
    }];
    
    [operation start];
}

//解压
+(void)unArchiveFromPath:(NSString*)fromPath toPath:(NSString*)toPath progress:(void (^)(CGFloat percentDecompressed))progress{
    //    下载之前删除之前的目标文件
    NSError* fileError = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:toPath]) {
        [fm removeItemAtPath:toPath error:&fileError];
        NSLog(@"删除之前的目标文件%@", fileError);
    }
    
    
    BOOL fileAtPathIsArchive = [UZKArchive pathIsAZip:fromPath];//判断是否是zip文件
    if (!fileAtPathIsArchive) {
        return;
    }
    
    NSError *archiveError = nil;
    UZKArchive* archive = [[UZKArchive alloc] initWithPath:fromPath error:&archiveError];
    [archive extractFilesTo:toPath overwrite:YES progress:^(UZKFileInfo * _Nonnull currentFile, CGFloat percentArchiveDecompressed) {
        if(progress) progress(percentArchiveDecompressed);
//        NSLog(@"解压进度%f", percentArchiveDecompressed);
    } error:&archiveError];
    
    //    解压完成后删除这个zip包
    NSError* deleteError = nil;
    if ([fm fileExistsAtPath:fromPath]) {
        //        [fm removeItemAtPath:fromPath error:&deleteError];
        [archive deleteFile:fromPath error:&deleteError];
        NSLog(@"删除ZIP源文件%@", fileError);
    }
    
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

//去除null
+ (NSString *) getBlankString:(id)string{
    if (string == nil || string == NULL) {
        return @"";
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return @"";
    }
    //    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
    //        return @"";
    //    }
    return [NSString stringWithFormat:@"%@", string];
}

@end
