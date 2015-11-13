//
//  ImageFilterViewController.m
//  MyTest Hello
//
//  Created by liuguangsheng on 15/11/11.
//
//

#import "ImageFilterViewController.h"
#import "ImageFilterCollectionViewCell.h"
#import "UIImage+Resize.h"
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>

#define SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_SCALE   ([UIScreen mainScreen].scale)

@interface ImageFilterViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,GLKViewDelegate> {

    UICollectionView *_collectionView;
    GLKView *_largeImageView;
    UIImage *_originalImage;
    CIContext *_context;
    CIImage * _outputImage;
}

@property (nonatomic, strong)NSMutableArray *collectionViewArray;

@property (nonatomic, strong)NSMutableArray *imageArray;

@end

@implementation ImageFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self performSelector:@selector(initData) withObject:nil afterDelay:0.5];
    // Do any additional setup after loading the view.
}

- (void)initData {
    _imageArray = [[NSMutableArray alloc]init];

    _collectionViewArray = [NSMutableArray arrayWithArray:@[@{@"filter":@"CIColorControls",@"name":@"原图"},
                                                            @{@"filter":@"CIPhotoEffectMono", @"name":@"单色"},
                                                            @{@"filter":@"CIPhotoEffectTonal", @"name":@"色调"},
                                                            @{@"filter":@"CIPhotoEffectNoir", @"name":@"黑白"},
                                                            @{@"filter":@"CIPhotoEffectFade", @"name":@"褪色"},
                                                            @{@"filter":@"CIPhotoEffectChrome", @"name":@"铬黄"},
                                                            @{@"filter":@"CIPhotoEffectProcess", @"name":@"冲印"},
                                                            @{@"filter":@"CIPhotoEffectTransfer", @"name":@"岁月"},
                                                            @{@"filter":@"CIPhotoEffectInstant", @"name":@"怀旧"}]];
    
    [_collectionView reloadData];


}

- (void)initView {
    
    self.view.backgroundColor = [UIColor whiteColor];
//    _originalImage = [UIImage imageNamed:@"testImage.jpg"];
    _originalImage = [UIImage imageNamed:@"test_h.jpg"];
    [self.view addSubview:_largeImageView];
    //collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-180, SCREEN_WIDTH, 180) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.scrollEnabled = YES;
    
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[ImageFilterCollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --collectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_collectionViewArray count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"collectionViewCell";
    ImageFilterCollectionViewCell *cell = [[ImageFilterCollectionViewCell alloc]init];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    
    [cell sizeToFit];
    if (!cell) {
        NSLog(@"无法创建cell");
    }
    NSDictionary *dic = [_collectionViewArray objectAtIndex:indexPath.row];
    cell.filterNameLabel.text = dic[@"name"];
    
    return cell;
    
}
#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 150);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark --UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:_originalImage];
    //创建滤镜
    CIFilter *filter = [CIFilter filterWithName:[_collectionViewArray objectAtIndex:indexPath.row][@"filter"] keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    EAGLContext *eaglContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _context = [CIContext contextWithEAGLContext:eaglContext];
    _outputImage = [filter outputImage];
    [_largeImageView removeFromSuperview];
    _largeImageView = nil;
    _largeImageView = [[GLKView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-200) context:eaglContext];
    _largeImageView.delegate = self;
    [self.view addSubview:_largeImageView];
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark --GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    CGFloat width;
    CGFloat height;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat viewWidth = view.bounds.size.width;
    CGFloat viewHeight = view.bounds.size.height;

    if (_originalImage.size.width/_originalImage.size.height>1) {
        width = viewWidth*SCREEN_SCALE;
        height = viewWidth*SCREEN_SCALE*_originalImage.size.height/_originalImage.size.width;
        y = (viewHeight - height/SCREEN_SCALE);
        
    }else {
        width = (viewHeight)*SCREEN_SCALE*_originalImage.size.width/_originalImage.size.height;
        height = (viewHeight)*SCREEN_SCALE;
        x = (viewWidth - width/SCREEN_SCALE);
    }
    
    if (_outputImage) {
        //这里重新计算了inRect，但是在5.5inch上x，y各有偏移，还不知道为什么
        [_context drawImage:_outputImage inRect:CGRectMake(x, y, width, height) fromRect:CGRectMake(0, 0, _originalImage.size.width, _originalImage.size.height)];
        
    }
   
}

@end
