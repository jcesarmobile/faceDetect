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
    
    // La añadimos a nuestra vista
    
    //[self.viewController.view addSubview:imagen];
    
    // Llamamos al método markFaces para poder detectar los rostros y sí los detecta pintarlos en pantalla
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform,
                                           0,-imagen.bounds.size.height);
    
    NSString * result = [self markFaces:imagen withTransform:transform];
    if (result != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
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


-(NSMutableString *)markFaces:(UIImageView *)imagenCara withTransform:(CGAffineTransform) transform
{
    NSMutableString * resultString = [[NSMutableString alloc]init];
    
    CIImage *imagen = [CIImage imageWithCGImage:imagenCara.image.CGImage];
    // Para el detector, utilizamos la constante "CIDetectorAccuracyHigh" la cual nos proporciona una precisión mejor pero requiere más tiempo de procesado
    // Más info en http://developer.apple.com/library/ios/#documentation/CoreImage/Reference/CIDetector_Ref/Reference/Reference.html
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // Creamos un array con todas las caras detectadas en la imagen
    NSArray *features = [detector featuresInImage:imagen];
    
    if ([features count]==0) {
        resultString = nil;
    }
    // Hacemos un bucle por si detecta más de un rostro en la imagen
    for (CIFaceFeature *faceFeature in features) {
        
        // Convertir coordenadas CoreImage a UIKit
        CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        [resultString appendString:NSStringFromCGRect(faceRect)];
        // Obtener el ancho de la cara
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        // UIView usando las dimensiones de la cara detectada
        UIView *faceView = [[UIView alloc] initWithFrame:faceRect];
        
        // Añadimos un borde alrededor del UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor blueColor] CGColor];
        
        //[self.viewController.view addSubview:faceView];
        
        // Ojo derecho
        if (faceFeature.hasRightEyePosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint rightEyePos = CGPointApplyAffineTransform(faceFeature.rightEyePosition, transform);
            
            // Creamos una UIView con el tamaño del ojo derecho
            UIView *rightEye = [[UIView alloc] initWithFrame:CGRectMake(rightEyePos.x - faceWidth * 0.15, rightEyePos.y - faceWidth * 0.15, faceWidth * 0.3, faceWidth * 0.3)];
            
            rightEye.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
            rightEye.center = rightEyePos;
            
            rightEye.layer.cornerRadius = faceWidth * 0.15;
            //[self.viewController.view addSubview:rightEye];
        }
        
        // Ojo izquierdo
        if (faceFeature.hasLeftEyePosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint leftEyePos = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);
            
            // Creamos una UIView con el tamaño del ojo izquierdo
            UIView *leftEye = [[UIView alloc] initWithFrame:CGRectMake(leftEyePos.x - faceWidth * 0.15, leftEyePos.y - faceWidth * 0.15, faceWidth * 0.3, faceWidth * 0.3)];
            
            leftEye.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
            leftEye.center = leftEyePos;
            
            leftEye.layer.cornerRadius = faceWidth * 0.15;
            //[self.viewController.view addSubview:leftEye];
        }
        
        // Boca
        if (faceFeature.hasMouthPosition) {
            
            // Convertir coordenadas CoreImage a UIKit
            CGPoint mouthPos = CGPointApplyAffineTransform(faceFeature.mouthPosition, transform);
            
            // Creamos una UIView con el tamaño de la boca
            UIView *mouth = [[UIView alloc] initWithFrame:CGRectMake(mouthPos.x - faceWidth * 0.20, mouthPos.y - faceWidth * 0.20, faceWidth * 0.40, faceWidth * 0.40)];
            
            mouth.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
            mouth.center = mouthPos;
            
            mouth.layer.cornerRadius = faceWidth * 0.20;
            //[self.viewController.view addSubview:mouth];
        }
    }
    
    return resultString;

}



@end
