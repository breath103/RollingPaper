//
//  NetworkTemplate.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 4..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "NetworkTemplate.h"
#import "SBJSON.h"


@implementation NetworkTemplate
+(ASIFormDataRequest*) requestForFacebookJoinWithMe : (id<FBGraphUser>) me
                                        accessToken : (NSString*) accesstoken{
    NSLog(@"%@",SERVER_HOST);
    NSString* joinWithFacebookURL = [SERVER_HOST stringByAppendingString:@"/user/joinWithFacebook"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:joinWithFacebookURL]];
    
    [request addPostValue:[me id]                    forKey:@"facebook_id"];
    [request addPostValue:[me objectForKey:@"name"]  forKey:@"name"];
    [request addPostValue:[me objectForKey:@"email"] forKey:@"email"];
    
    //생일부분이 mysql에는 yyyy-mm-dd 으로 넣어야 하는데 올때는 mm/dd/yyyy로온다. 이걸 재정렬
    NSString* birthdayString = [me objectForKey:@"birthday"];
    NSArray* dateComponent = [birthdayString componentsSeparatedByString:@"/"];
    birthdayString = [NSString stringWithFormat:@"%@-%@-%@",
                      [dateComponent objectAtIndex:2],
                      [dateComponent objectAtIndex:0],
                      [dateComponent objectAtIndex:1]];
    
    [request addPostValue:birthdayString forKey:@"birthday"];
    [request addPostValue: [[((NSDictionary*)[me objectForKey:@"picture"])objectForKey:@"data"] objectForKey:@"url"]  forKey:@"picture"];
    [request addPostValue:accesstoken forKey:@"facebook_accesstoken"];
    
    return request;
}
+(ASIFormDataRequest*) requestForUploadImageContentWithUserIdx : (NSString*) useridx
                                                        entity : (ImageContent*) entity
                                                         image : (NSData*) image{
    NSString* joinWithFacebookURL = [SERVER_HOST stringByAppendingString:@"/paper/addContent/image"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:joinWithFacebookURL]];
  
    [request addPostValue:useridx           forKey:@"user_idx"];
    [request addPostValue:entity.paper_idx  forKey:@"paper_idx"];
    
 // [request addPostValue:image     forKey:@"image"];
    [request setData : image
        withFileName : @"photo1.png"
      andContentType : @"image/png"
              forKey : @"image"];
    
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.rotation forKey:@"rotation"];
    
    return request;
}
+(ASIFormDataRequest*) requestForCreateRollingPaperWithUserIdx : (NSString*) creator_idx
                                                         title : (NSString*) title
                                                  target_email : (NSString*) target_email
                                                        notice : (NSString*) notice
                                                  receiverFBid : (NSString*) receiver_fb_id
                                                  receiverName : (NSString*) receiver_name
                                                  receieveTime : (NSString*) receiveTime{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/create"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:creator_idx     forKey:@"creator_idx"];
    [request addPostValue:title           forKey:@"title"];
    [request addPostValue:target_email    forKey:@"target_email"];
    [request addPostValue:notice          forKey:@"notice"];
    [request addPostValue:receiver_fb_id  forKey:@"r_fb_id"];
    [request addPostValue:receiver_name   forKey:@"r_name"];
    [request addPostValue:receiveTime     forKey:@"r_time"];
    
    return request;
}
+(ASIFormDataRequest*) requestForRollingPaperListWithUserIdx : (NSString*) useridx{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/user/paperList"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:useridx forKey:@"user_idx"];
    return request;
}
+(ASIFormDataRequest*) requestForInviteFacebookFriends : (NSArray*) facebookFriends
                                               ToPaper : (NSString*) paper_idx
                                              withUser : (NSString*) user_idx{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/inviteWithFacebookID"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    SBJSON* json = [[SBJSON alloc] init];
    [request addPostValue:paper_idx forKey:@"paper_idx"];
    [request addPostValue:user_idx  forKey:@"user_idx"];
    [request addPostValue:[json stringWithObject:facebookFriends] forKey:@"facebook_friends"];
    return request;
}
+(ASIFormDataRequest*) requestForRollingPaperContents : (NSString*) paper_idx
                                            afterTime : (long) timestamp {
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/contents"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper_idx  forKey:@"paper_idx"];
    [request addPostValue:[NSString stringWithFormat:@"%ld",timestamp] forKey:@"after_time"];
    return request;
}
+(ASIFormDataRequest*) requestForUploadSoundContentWithUserIdx : (NSString*) useridx
                                                        entity : (SoundContent*) entity
                                                         sound : (NSData*) sound{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/addContent/sound"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    [request addPostValue:useridx           forKey:@"user_idx"];
    [request addPostValue:entity.paper_idx  forKey:@"paper_idx"];
    
    [request setData : sound
        withFileName : @"sound1.wav"
      andContentType : @"audio/wav"
              forKey : @"sound"];
    
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    return request;
}
@end
