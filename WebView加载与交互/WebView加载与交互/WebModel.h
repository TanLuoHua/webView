//
//  WebModel.h
//  git发贴专业测试
//
//  Created by Mac on 16/4/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <UnzipKit.h>

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


/**
 *  @author 嘴爷, 2016-05-03 09:05:04
 *
 *  @brief 解压文件
 *
 *  @param fromPath 待解压文件的位置
 *  @param toPath   解压到的位置
 *  @param progress 解压进度
 */
+(void)unArchiveFromPath:(NSString*)fromPath toPath:(NSString*)toPath progress:(void (^)(CGFloat percentDecompressed))progress;

/**
 *  @author 嘴爷, 2016-05-03 10:05:27
 *
 *  @brief 返回的绝对为字符串，不管是NULL nil  还是数字
 *
 *  @param string 待处理的对象
 *
 *  @return 字符串
 */
+ (NSString *) getBlankString:(id)string;

@end
