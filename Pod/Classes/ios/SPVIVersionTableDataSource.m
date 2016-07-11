//
//  SPVIVersionTableDataSource.m
//  Pods
//
//  Created by Claus Weymann on 15/06/15.
//
//

#import "SPVIVersionTableDataSource.h"
#import "SPVIVersionIntrospection.h"
#import "SPVIDependencyInformation.h"

#import <TSMarkdownParser/TSMarkdownParser.h>

NSString *kSPVIVersionIntrospectionSectionKey_title = @"versionIntrospectionSectionTitle";
NSString *kSPVIVersionIntrospectionSectionTitle_version = @"versionIntrospectionSectionTitleVersions";
NSString *kSPVIVersionIntrospectionSectionTitle_license = @"versionIntrospectionSectionTitleLicenses";
NSString *kSPVIVersionIntrospectionSectionKey_data = @"versionIntrospectionSectionData";
NSString *kSPVIVersionIntrospection_VersionCell = @"versionIntrospectionVersionCell";
NSString *kSPVIVersionIntrospection_LicenseCell = @"versionIntrospectionLicenseCell";

@interface SPVIVersionTableDataSource()

@property (nonatomic,strong) NSMutableArray* sortedDataSource;

@end

@implementation SPVIVersionTableDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    [tableView registerNib:[UINib nibWithNibName:@"VersionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kSPVIVersionIntrospection_VersionCell];
    [tableView registerNib:[UINib nibWithNibName:@"LicenseTableViewCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:kSPVIVersionIntrospection_LicenseCell];
    
    id dataItem = [self dataItemAtIndexPath:indexPath];
    
    if ([dataItem isKindOfClass: [SPVIDependencyInformation class]]) {
        SPVIDependencyInformation* dependencyInfo = (SPVIDependencyInformation*)dataItem;
        cell = [tableView dequeueReusableCellWithIdentifier:kSPVIVersionIntrospection_VersionCell forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSPVIVersionIntrospection_VersionCell];
        }
        ((UILabel*)[cell viewWithTag:10]).text = dependencyInfo.name;
        ((UILabel*)[cell viewWithTag:11]).text = dependencyInfo.version;
        ((UILabel*)[cell viewWithTag:12]).text = dependencyInfo.gitHash;
    }
    else
    {
        if ([dataItem isKindOfClass:[NSAttributedString class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:kSPVIVersionIntrospection_LicenseCell forIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSPVIVersionIntrospection_LicenseCell];
            }
            ((UITextView*)[cell viewWithTag:20]).attributedText = dataItem;
        }
    }
    
    
    return cell;
}

-(id)dataItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* sectionArray = [self arrayForSection:[indexPath section]];
    return sectionArray[[indexPath row]];
}

-(NSArray*)arrayForSection:(NSInteger)section
{
    return self.dataSource[section][kSPVIVersionIntrospectionSectionKey_data];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource[section][kSPVIVersionIntrospectionSectionKey_title];
}

-(NSMutableArray *)sortedDataSource
{
    if(!_sortedDataSource)
    {
        _sortedDataSource = [NSMutableArray array];
        NSArray* sortedValues;
       
        sortedValues = [[[SPVIVersionIntrospection sharedIntrospection].versionInformation allValues] sortedArrayUsingSelector:@selector(compare:)];
        
        for (SPVIDependencyInformation* info in sortedValues) {
            [_sortedDataSource addObject:info];
        }
    }
    return _sortedDataSource;
}

-(NSAttributedString*)licenseMarkdown
{
    if(!_licenseMarkdown)
    {
        NSString* markdownString;
        if ([self.licenseIgnoreList count] > 0) {
            NSString* acknowledgementsPlistPath = [[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"plist"];
            NSDictionary* licenseDictionary = [NSDictionary dictionaryWithContentsOfFile:acknowledgementsPlistPath];
            NSMutableDictionary* licenseForDependency = [NSMutableDictionary dictionary];
            for (NSDictionary* entryDict in licenseDictionary[@"PreferenceSpecifiers"]) {
                NSString* dependency = entryDict[@"Title"];
                NSString* license = entryDict[@"FooterText"];
                if ([dependency length] > 0 && [license length] > 0 && ![self.licenseIgnoreList containsObject:dependency]) {
                    licenseForDependency[dependency] = license;
                }
            }
            NSMutableArray* orderedDependencies = [NSMutableArray arrayWithArray:[[licenseForDependency allKeys] sortedArrayUsingSelector:@selector(compare:)]];
            NSString* headerTitle = @"Acknowledgements";
            [orderedDependencies removeObject:headerTitle];
            
            NSMutableString* generatedMarkdown = [NSMutableString stringWithFormat:@"# %@\n\n %@\n\n", headerTitle, licenseForDependency[headerTitle]];
            for (NSString* dependency in orderedDependencies) {
                [generatedMarkdown appendFormat:@"## %@\n\n%@\n\n",dependency,licenseForDependency[dependency]];
            }
            markdownString = [NSString stringWithString:generatedMarkdown];
        }
        else
        {
            NSString* acknowledgementsMarkdownPath = [[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"markdown"];
            NSError* error;
            markdownString = [NSString stringWithContentsOfFile:acknowledgementsMarkdownPath encoding:NSUTF8StringEncoding error:&error];
            if(error)
            {
                NSLog(@"ERROR while reading Acknowledgements.markdown, make sure you copied it during post install phase in your podfile");
                return nil;
            }
        }
        
        NSAttributedString *string = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:markdownString];
        
        _licenseMarkdown = string ?: [[NSAttributedString alloc] initWithString:@""];
    }
    return _licenseMarkdown;
}

-(NSArray*)dataSource
{
    NSMutableArray* datasource = [NSMutableArray array];
    if(self.licenseMarkdown.length > 0)
    {
        [datasource addObject:@{kSPVIVersionIntrospectionSectionKey_title:kSPVIVersionIntrospectionSectionTitle_license,kSPVIVersionIntrospectionSectionKey_data:@[self.licenseMarkdown]}];
    }
    [datasource addObject:@{kSPVIVersionIntrospectionSectionKey_title:kSPVIVersionIntrospectionSectionTitle_version,kSPVIVersionIntrospectionSectionKey_data:self.sortedDataSource}];
    return datasource;
}

-(void)setExplicitDependencyOrder:(NSDictionary *)explicitDependencyOrder
{
    [SPVIVersionIntrospection sharedIntrospection].explicitDependencyOrder = explicitDependencyOrder;
}

-(NSDictionary *)explicitDependencyOrder
{
    return [SPVIVersionIntrospection sharedIntrospection].explicitDependencyOrder;
}
@end
