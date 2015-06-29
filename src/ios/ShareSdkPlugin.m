
#import "ShareSdkPlugin.h"
#import <ShareSDK/ShareSDK.h>

@implementation ShareSdkPlugin
- (void) send:(CDVInvokedUrlCommand*)command;
{
    __weak ShareSdkPlugin* weakSelf = self;
    
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *content = [args objectForKey:@"content"];
    NSString *title = [args objectForKey:@"title"];
    // NSString *description = [args objectForKey:@"description"];
    NSString *url = [args objectForKey:@"url"];
    NSNumber *mediaType = [[NSNumber alloc] initWithInt:SSPublishContentMediaTypeImage];
    if(nil != [args objectForKey:@"mediaType"]){
        mediaType = [args objectForKey:@"mediaType"];
    }
    NSString *imageUrl = [args objectForKey:@"imageUrl"];
    NSData *imageData = [self getNSDataFromURL: imageUrl];
    
    //NSString *imageNamed = [args objectForKey:@"imageNamed"];
    
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithData:imageData
                                                                     fileName:nil
                                                                     mimeType:nil]
                                                title:title
                                                  url:url
                                          description:@""
                                            mediaType:mediaType.intValue];
    [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                         content:INHERIT_VALUE
                                           title:INHERIT_VALUE
                                             url:INHERIT_VALUE
                                      thumbImage:[ShareSDK imageWithData:imageData
                                                                fileName:nil
                                                                mimeType:nil]
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    [publishContent addWeixinTimelineUnitWithType:INHERIT_VALUE
                                          content:INHERIT_VALUE
                                            title:INHERIT_VALUE
                                              url:INHERIT_VALUE
                                       thumbImage:[ShareSDK imageWithData:imageData
                                                                 fileName:nil
                                                                 mimeType:nil]
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    //[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                NSDictionary *response = nil;
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                    response = @{
                                                 @"code": @"0",
                                                 @"message": @"",
                                                 };
                                    
                                    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
                                    
                                    [weakSelf.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                    
                                    response = @{
                                                 @"code": [[NSString alloc] initWithFormat:@"%d", [error errorCode]],
                                                 @"message": [error errorDescription],
                                                 };
                                    
                                    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
                                    
                                    [weakSelf.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
                                }
                            }];
}

- (NSData *)getNSDataFromURL:(NSString *)url
{
    __block NSData* data = nil;
    
    NSURL *uri = [NSURL URLWithString:url];
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
    {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    } else if([url hasPrefix:@"file://"]){
        data = [[NSFileManager defaultManager] contentsAtPath:[uri path]];
    }
    return data;
}


@end


