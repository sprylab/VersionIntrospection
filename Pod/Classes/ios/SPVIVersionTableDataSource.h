//
//  SPVIVersionTableDataSource.h
//  Pods
//
//  Created by Claus Weymann on 15/06/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kSPVIVersionIntrospectionSectionKey_title;
extern NSString *kSPVIVersionIntrospectionSectionKey_data;
extern NSString *kSPVIVersionIntrospectionSectionTitle_version;
extern NSString *kSPVIVersionIntrospectionSectionTitle_license;
extern NSString *kSPVIVersionIntrospection_VersionCell;
extern NSString *kSPVIVersionIntrospection_LicenseCell;

@interface SPVIVersionTableDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, strong) NSAttributedString* licenseMarkdown;
@property (nonatomic, strong) NSDictionary* explicitDependencyOrder;
@property (nonatomic, strong) NSSet* licenseIgnoreList;

-(id)dataItemAtIndexPath:(NSIndexPath*)indexPath;

@end
