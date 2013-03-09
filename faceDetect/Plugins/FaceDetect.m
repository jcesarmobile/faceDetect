//
//  FaceDetect.m
//  faceDetect
//
//  Created by Admin on 03/03/13.
//
//

#import "FaceDetect.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation FaceDetect

- (void)detect:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString *url_string = [[command.arguments objectAtIndex:0] objectForKey:@"url_imagen"];
    NSLog(@"url = %@",url_string);
    NSURL *url = [NSURL URLWithString:url_string];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *Realimage = [[UIImage alloc] initWithData:data];
    
    UIImageView *imagen = [[UIImageView alloc] initWithImage:[self resizeImage:Realimage]];
    

    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform,
                                           0,-imagen.bounds.size.height);
    
    NSArray * result = [self markFaces:imagen withTransform:transform];
    if (result != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No faces"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(UIImage *)resizeImage:(UIImage *)image {
    
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    int width, height;
    
    width = [image size].width;
    height = [image size].height;
    
    CGContextRef bitmap;
    
    if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    }
    
    if (image.imageOrientation == UIImageOrientationLeft) {
        NSLog(@"image orientation left");
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -height);
        
    } else if (image.imageOrientation == UIImageOrientationRight) {
        NSLog(@"image orientation right");
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -width, 0);
        
    } else if (image.imageOrientation == UIImageOrientationUp) {
        NSLog(@"image orientation up");
        
    } else if (image.imageOrientation == UIImageOrientationDown) {
        NSLog(@"image orientation down");
        CGContextTranslateCTM (bitmap, width,height);
        CGContextRotateCTM (bitmap, radians(-180.));
        
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}


-(NSArray *)markFaces:(UIImageView *)imagenCara withTransform:(CGAffineTransform) transform
{
    NSMutableArray * resultArray = [[NSMutableArray alloc]init];
    
    CIImage *imagen = [CIImage imageWithCGImage:imagenCara.image.CGImage];

    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // Creamos un array con todas las caras detectadas en la imagen
    NSArray *features = [detector featuresInImage:imagen];
    
    if ([features count]==0) {
        resultArray = nil;
    }
    // Hacemos un bucle por si detecta más de un rostro en la imagen
    for (CIFaceFeature *faceFeature in features) {
        NSMutableDictionary * faceDict = [[NSMutableDictionary alloc]init];
        // Convertir coordenadas CoreImage a UIKit
        CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);

        [faceDict setValue:NSStringFromCGRect(faceRect) forKey:@"face"];

        // Ojo derecho
        if (faceFeature.hasRightEyePosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint rightEyePos = CGPointApplyAffineTransform(faceFeature.rightEyePosition, transform);
            [faceDict setValue:NSStringFromCGPoint(rightEyePos) forKey:@"right_eye"];
            
        }
        
        // Ojo izquierdo
        if (faceFeature.hasLeftEyePosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint leftEyePos = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);
            [faceDict setValue:NSStringFromCGPoint(leftEyePos) forKey:@"left_eye"];
            
        }
        
        // Boca
        if (faceFeature.hasMouthPosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint mouthPos = CGPointApplyAffineTransform(faceFeature.mouthPosition, transform);
            [faceDict setValue:NSStringFromCGPoint(mouthPos) forKey:@"mouth"];
            
        }
        
        [resultArray addObject:faceDict];
    }
    
    return resultArray;

}



@end
