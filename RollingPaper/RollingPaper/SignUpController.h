//
//  SignUpController.h
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 24..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
- (IBAction)onTouchSignUp:(id)sender;

@end
