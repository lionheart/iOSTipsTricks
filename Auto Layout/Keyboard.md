Adjusting Height on Keyboard Appearance / Disappearance
=======================================================

I wanted to start this snippet compilation off with something that is fairly common, but lacks much in the way of resources online: how to resize a view when a keyboard appears using Auto Layout.

So, without further adieu, here we go.

Setting Up
----------

The first thing to do is to define our containing view controller, the view, and the bottom constraint that we'll use to adjust its size.

Here's [HeightAdjustingViewController.h](HeightAdjustingViewController.h). We don't need to expose any public properties, so it's pretty bare.

```objc
@interface HeightAdjustingViewController : UIViewController

@end
```

Now, in the class extension in our [implementation file](HeightAdjustingViewController.m), we define a `view` and a `bottomConstraint`, which will adjust the bottom position of our view when the keyboard appears and disappears.

```objc
@property (nonatomic, strong) UIView *adjustingView;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
```

We also define two methods to send the keyboard hide and show notifications to.

```objc
- (void)keyboardDidHide:(NSNotification *)sender;
- (void)keyboardDidShow:(NSNotification *)sender;
```

Defining the View
-----------------

We can now move on to the implementation. In our `viewDidLoad` method, we'll set up the view, add observers for the hide and show notifications, and define our `bottomConstraint`.

```objc
- (void)viewDidLoad {
    [super viewDidLoad]

    self.adjustingView = [[UIView alloc] init];
    self.adjustingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.adjustingView];

    NSDictionary *views = @{@"view": self.adjustingView,
                            @"top": self.topLayoutGuide };

    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:[top][view] options:0 metrics:nil views:views]];

    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.adjustingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.bottomConstraint];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;
}
```

Notification Handlers
---------------------

Great, we've got everything set up. Our visual layout constraints pin the adjusting view to the topLayoutGuide, and the `bottomConstraint` pins the bottom of the view to the bottomLayoutGuide (which we'll soon adjust using the constant).

Now it's time to set up our keyboard notification handlers.

The UIKeyboardDidShowNotification sends a NSNotification with a userInfo value containing a key that has the final CGRect of the keyboards position on the screen. We're going to take that rectangle,

```objc
CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
```

convert it into the coordinate system of the current view,

```objc
CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
```

and then adjust the bottom constraint by the starting position of the keyboard in the Y-axis as offset from the height of the current superview.

```objc
self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
```

I know, it's a mouthful. After updating the constraint's constant, we call `layoutIfNeeded` to re-layout our subviews.

Here's the completed `keyboardDidShow:`:

```objc
- (void)keyboardDidShow:(NSNotification *)sender {
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    [self.view layoutIfNeeded];
}
```

Now, keyboardDidHide is a bit simpler. We don't care what the keyboard frame is; we just want to put things back to where they were before (pin the adjustingView back to the bottom). We do this by just reassigning the bottomConstraint's constant back to 0.

```objc
- (void)keyboardDidHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}
```

Wrapping Up
-----------

And that's it. You can browse the files in their entirety below. Of course, I didn't add a text field that would make the keyboard appear, but I'll leave that as an exercise for the reader. Enjoy!

File List
---------

* [HeightAdjustingViewController.h](HeightAdjustingViewController.h)
* [HeightAdjustingViewController.m](HeightAdjustingViewController.m)

