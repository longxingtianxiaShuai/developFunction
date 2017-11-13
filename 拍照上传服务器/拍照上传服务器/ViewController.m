//
//  ViewController.m
//  拍照上传服务器
//
//  Created by BIM on 2017/11/13.
//  Copyright © 2017年 BIM. All rights reserved.
//

/*
 上传图片的两种方式
 1 使用NSData数据流传图片
 
 NSString *imageURl = @"";
 
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
 
 manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"text/html"];
 [manager POST:imageURl parameters:nil constructingBodyWithBlock:^(idformData) {
 
 [formData appendPartWithFileData:UIImageJPEGRepresentation(photo, 1.0) name:@"text" fileName:@"test.jpg" mimeType:@"image/jpg"];
 
 } success:^(AFHTTPRequestOperation *operation, id responseObject) {
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
 }];
 
 
 2 使用 使用Base64字符串传图片
 NSData *data = UIImageJPEGRepresentation(photo, 1.0);
 
 NSString *pictureDataString=[data base64Encoding];
 
 NSDictionary * dic  = @{@"verbId":@"modifyUserInfo",@"deviceType":@"ios",@"userId":@"",@"photo":pictureDataString,@"mobileTel":@""};
 
 [manager POST:@"" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
 
 if ([[responseObject objectForKey:@"flag"] intValue] == 0) {
 
 }else{
 
 }
 
 }
 
 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
 }];
 
 
 */

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
//@property (nonatomic,weak)UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSMutableDictionary *imageDictionary;
@property (nonatomic,strong)AFHTTPSessionManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.backgroundColor = [UIColor redColor];
     _imageDictionary = [NSMutableDictionary dictionary];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    self.manager = manager;
    
    
    
    // 在这里我们可以进行图片的修改,保存,或者视频的保存
    /*
    UIImage *image = [UIImage imageNamed:@"待交纳"];
    // 压缩图片
    UIImage *photoIamge = [self resetSizeOfImageData:image maxSize:400];
    NSData *data = UIImageJPEGRepresentation(photoIamge, 1.0f);
    NSString *photoString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    NSData *photoData = [[NSData alloc] initWithBase64EncodedString:photoString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image2 = [UIImage imageWithData:photoData];
    _imageView.image = image2;
     */
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 拍照
- (IBAction)takeAPicture:(id)sender {
    [self handlePhoto];
}

// 上传
- (IBAction)post:(id)sender {
    NSString *photoString = [_imageDictionary objectForKey:@"图片"];
    NSString *urlString = [NSString stringWithFormat:@"上传路径url"];
    [_manager POST:urlString parameters:@{@"headImage":photoString} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 上传成功后把图片保存到本地   也可以不保存 如果直接在这里设置imageview的图片也可以不保存
        NSLog(@"上传成功");
        // 设置一个图片的存储路径
       // NSString *path_sandox = NSHomeDirectory();
        //NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/test.png"];
        // 把图片保存到指定路径
       NSData *photoData = [[NSData alloc] initWithBase64EncodedString:photoString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:photoData];
        _imageView.image = image;
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
    
    // manager2
    
}

//截屏
- (IBAction)Screenshots:(id)sender {
}

#pragma mark 调用相机
- (void)handlePhoto{
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        NSLog(@"不可用");
        return;
    }
    
    // 初始化图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 设置拍照时的下方工具栏是否显示 ,如果需要自定义拍摄界面,则可以把该工具栏隐藏
    imagePicker.allowsEditing = YES;
    //self.imagePicker = imagePicker;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    

}

// 选取照片后调用这个方法 以data的形式上传
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // 在这里我们可以进行图片的修改,保存,或者视频的保存
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 压缩图片
    UIImage *photoIamge = [self resetSizeOfImageData:image maxSize:400];
    NSData *data = UIImageJPEGRepresentation(photoIamge, 1.0f);
    NSString *photoString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [_imageDictionary setObject:photoString forKey:@"图片"];
   
    [self dismissViewControllerAnimated:YES completion:nil];
}


//  压缩图片
- (UIImage *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    //    NSUInteger sizeOrigin = [imageData length];
    //    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    while ([imageData length]/1024 > maxSize)
    {
        imageData = UIImageJPEGRepresentation ([UIImage imageWithData:imageData], 0.50);
    }
    return [UIImage imageWithData:imageData];
}


@end
