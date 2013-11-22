#项目初衷
让使用网络图片像使用本地图片一样简单。

关于图片缓存开源项目有不少，我个人觉得最棒的应该是 path 的 
[FastImageCache](https://github.com/path/FastImageCache)
，但是使用起来还是比较麻烦的，我们还是需要自己管理图片的下载，检测/清理缓存等。在多个controller间导航时，还需要考虑图片下载的暂停/继续，因为优先下载当前controller中的图片对用户的体验更好。

#关于OWWebImage

相比较而言，这个项目没有FastImageCache高端大气,OWWebImage使用ASIHttpReqeust下载图片，使用CoreData来缓存图片，使用CATiledLayer的drawLayer: inContext: 来异步渲染图片。
封装了Web图片从下载，缓存，到呈现的逻辑，只需像调用本地图片一样简单地调用web图片。

项目使用了[iOS Universal Framework](https://github.com/kstenerud/iOS-Universal-Framework)
这个打包framework的Xcode插件，运行这个项目，需要先安装此插件。

项目里的库文件ASIHTTPRequest.framework也是使用[iOS Universal Framework](https://github.com/kstenerud/iOS-Universal-Framework)编译ASIHTTPRequest项目得来

#代码说明
初始化OWImageManager
	
	
	imageManager = [[OWImageManager alloc] init];
	
	
项目通过宏MAX_CACHE_COUNT设置了图片缓存的上限，超过上限时，离最近访问时间最早的图片将会被清除，想要某类图片（比如分类的icon）不被自动清除，需要设置相应的OWImageManager的setImageSavedForever为YES

	[imageManager setImageSavedForever:YES];
	
实列化用于渲染图片至屏幕的OWImageView
	
	webImageView = [[OWImageView alloc] initWithFrame:frame];
	//设置圆角大小，这个圆角的设置不会影响视图动画时的性能
    [webImageView setCornerRadius:12];
    [webImageView setBorderColor:[UIColor grayColor]];
    //边框线的宽度最好设置为0.5的倍数
    [webImageView setBorderWidth:1];
    [self.view addSubview:webImageView]
    
    [webImageView setImageManager:imageManager];
    [webImageView setImageWithURLString:url];
	

push/pop controller时 暂停/继续 下载

	- (void)viewDidAppear:(BOOL)animated
	{
    	[super viewDidAppear:animated];
    	[imageManager suspendWebImageQueue:NO];
	}

	- (void)viewDidDisappear:(BOOL)animated
	{
    	[super viewDidDisappear:animated];
    	[imageManager suspendWebImageQueue:YES];
	}




