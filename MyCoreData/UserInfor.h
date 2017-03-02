//
//  UserInfor.h
//  MyCoreData
//
//  Created by Taurus on 16/5/28.
//  Copyright © 2016年 Taurus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserInfor : NSManagedObject

@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, retain) NSString *age;
@property (readwrite, nonatomic, retain) NSString *sex;

@end

