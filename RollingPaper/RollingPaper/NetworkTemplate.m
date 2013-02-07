//
//  NetworkTemplate.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 4..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "NetworkTemplate.h"
#import <JSONKit.h>
#import "UEFileManager.h"
#import "RollingPaper.h"

@implementation NetworkTemplate

+(ASIFormDataRequest*) requestForPhoneAuth : (NSString*) phone{
    NSString* phoneAuthURL = [SERVER_HOST stringByAppendingString:@"/user/phoneAuth"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:phoneAuthURL]];
    
    [request addPostValue:phone forKey:@"phone"];
    
    return request;
}
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

+(ASIFormDataRequest*) requestForEditRollingPaper : (RollingPaper*) paper{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/edit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper.idx.stringValue forKey:@"paper_idx"];
    [request addPostValue:paper.title           forKey:@"title"];
    [request addPostValue:paper.target_email    forKey:@"target_email"];
    [request addPostValue:paper.notice          forKey:@"notice"];
    [request addPostValue:paper.background      forKey:@"background"];
    
    return request;
}
+(ASIFormDataRequest*) requestForInviteFacebookFriends : (NSArray*) facebookFriends
                                               ToPaper : (NSString*) paper_idx
                                              withUser : (NSString*) user_idx{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/inviteWithFacebookID"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper_idx forKey:@"paper_idx"];
    [request addPostValue:user_idx  forKey:@"user_idx"];
    [request addPostValue:[facebookFriends JSONString] forKey:@"facebook_friends"];
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


+(ASIFormDataRequest*) requestForSynchronizePaper : (RollingPaper*) entity{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/edit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    /*
    [request addPostValue:entity.idx      forKey:@"idx"];
    [request addPostValue:entity.rotation forKey:@"rotation"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.image    forKey:@"image"];
     */
    return request;
}



+(ASIFormDataRequest*) requestForQuitRoomWithUserIdx : (NSString*) user_idx
                                               paper : (NSString*) paper_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/quit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:user_idx forKey:@"user"];
    [request addPostValue:paper_idx forKey:@"paper"];
    return request;
}

+(ASIFormDataRequest*) requestForSearchingFacebookFriendUsingRollingPaper : (NSString*) user_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/user/isFacebookFriendUsingRollingPaper"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:user_idx forKey:@"user_idx"];
    return request;
}




@end
