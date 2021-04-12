//
//  NSImageUtil.m
//  path_provider_macos
//
//  Created by jinglong cai on 2021/4/12.
//

#import "NSImageUtil.h"

@implementation NSImageUtil

+ (NSData *)convertToData:(NSImage *)image formatType:(PMThumbFormatType)type quality:(float)quality {
  NSData *imageData = [image TIFFRepresentation];
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
  NSData *resultData;
  if (type == PMThumbFormatTypePNG) {
    resultData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
  } else {
    resultData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:@{
        NSImageCompressionFactor: @(quality)
    }];
  }

  return resultData;

}


@end
