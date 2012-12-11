//
//  HOStringSenseUnitTests.m
//  HOStringSenseUnitTests
//
//  Created by Dirk on 11.12.12.
//
//

#import "HOStringSenseUnitTests.h"
#import "HOStringHelper.h"

@implementation HOStringSenseUnitTests {
    HOStringHelper *helper;
}

- (void)setUp
{
    [super setUp];    
    helper = [HOStringHelper new];
}

- (void)tearDown
{
    [helper release];
    [super tearDown];
}

- (void)doTestEscapedString:(NSString *)s
{
    NSLog(@"s|%@", s);
    STAssertTrue(!!s, nil);
    id a = [helper unescapeString:s];
    NSLog(@"a|%@", a);
    STAssertTrue(!!a, nil);
    id b = [helper escapeString:a];
    NSLog(@"b|%@", b);
    STAssertTrue(!!b, nil);
    STAssertEqualObjects(s, b, nil);
}

- (void)testEscapedStrings
{
    [self doTestEscapedString:@"abc"];
    [self doTestEscapedString:@"(?<![\\\\d\\\\,\\\\.])\\n(\\\\d+([\\\\,\\\\.\\\\\\']\\\\d\\\\d\\\\d)*\\n(?![\\\\d])([\\\\,\\\\.]\\n([\\\\-\\\\–\\\\—\\\\―]|\\\\d\\\\d))?)\\n(?![\\\\d\\\\,\\\\.])"];
    // [self doTestEscapedString:@"(?<![\\d\\,\\.])\n(\\d+([\\,\\.\\\']\\d\\d\\d)*\n(?![\\d])([\\,\\.]\n([\\-\\–\\—\\―]|\\d\\d))?)\n(?![\\d\\,\\.])"];
}

@end
