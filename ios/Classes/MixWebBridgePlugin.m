#import "MixWebBridgePlugin.h"
#import <objc/runtime.h>
#import <webview_flutter_wkwebview/FlutterWebView.h>

void mixweb_hook_class_swizzleMethodAndStore(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface FLTWebViewController (Hooker)

@end

@implementation FLTWebViewController (Hooker)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mixweb_hook_class_swizzleMethodAndStore(self, @selector(initWithFrame:viewIdentifier:arguments:binaryMessenger:), @selector(mix_initWithFrame:viewIdentifier:arguments:binaryMessenger:));
    });
}

- (instancetype)mix_initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
{
    NSString *injectedjs;
    NSString *nUserAgent;

    NSString *userAgent = args[@"userAgent"];
    if ([userAgent hasPrefix:@"<injectedjs>"] && [userAgent containsString:@"</injectedjs>"]) {
        NSArray *parts = [userAgent componentsSeparatedByString:@"</injectedjs>"];
        if (parts.count == 2) {
            injectedjs = [parts[0] substringFromIndex:@"<injectedjs>".length];
            nUserAgent = [@"" isEqualToString:parts[1]] ? nil : parts[1];
        }
    }
    if (injectedjs == nil) {
        return [self mix_initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:messenger];
    }
    
    NSMutableDictionary *nargs = [args mutableCopy];
    if (nUserAgent) nargs[@"userAgent"] = nUserAgent;
    else [nargs removeObjectForKey:@"userAgent"];

    NSMutableDictionary *settings = [nargs[@"settings"] mutableCopy];
    if (nUserAgent) settings[@"userAgent"] = nUserAgent;
    else [settings removeObjectForKey:@"userAgent"];
    nargs[@"settings"] = settings;
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:injectedjs options:NSDataBase64DecodingIgnoreUnknownCharacters];
    injectedjs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    FLTWebViewController *vc = [self mix_initWithFrame:frame viewIdentifier:viewId arguments:nargs binaryMessenger:messenger];
    WKUserScript *wrapperScript = [[WKUserScript alloc] initWithSource:injectedjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [vc.webView.configuration.userContentController addUserScript:wrapperScript];
    return vc;
}

@end

@implementation MixWebBridgePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"mix_web_bridge"
            binaryMessenger:[registrar messenger]];
  MixWebBridgePlugin* instance = [[MixWebBridgePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

@end
