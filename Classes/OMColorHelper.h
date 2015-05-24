//
//  OMColorHelper.h
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef enum OMColorType {
	OMColorTypeNone = 0,
	
	OMColorTypeUIRGBA,				//[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeUIRGBAInit,			//[[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeUIWhite,				//[UIColor colorWithWhite:0.5 alpha:1.0]
	OMColorTypeUIWhiteInit,			//[[UIColor alloc] initWithWhite:0.5 alpha:1.0]
	OMColorTypeUIConstant,			//[UIColor redColor]
	
	OMColorTypeNSRGBACalibrated,	//[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeNSRGBADevice,		//[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeNSWhiteCalibrated,	//[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]
	OMColorTypeNSWhiteDevice,		//[NSColor colorWithDeviceWhite:0.5 alpha:1.0]
	OMColorTypeNSConstant,			//[NSColor redColor]
    
    OMColorTypeSKRGBA,              //[SKColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeSKRGBAInit,			//[[SKColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
    OMColorTypeSKWhite,				//[SKColor colorWithWhite:0.5 alpha:1.0]
    OMColorTypeSKWhiteInit,			//[[SKColor alloc] initWithWhite:0.5 alpha:1.0]
    OMColorTypeSKConstant,          //[SKColor redColor]
	
} OMColorType;

BOOL OMColorTypeIsNSColor(OMColorType colorType) { return colorType >= OMColorTypeNSRGBACalibrated && colorType <= OMColorTypeNSConstant; }
BOOL OMColorTypeIsSKColor(OMColorType colorType) { return colorType >= OMColorTypeSKRGBA; }

//TODO: Maybe support HSB and CMYK color types...

@class OMColorFrameView, OMPlainColorWell;

@interface OMColorHelper : NSObject {
	
	OMPlainColorWell *_colorWell;
	OMColorFrameView *_colorFrameView;
	NSRange _selectedColorRange;
	OMColorType _selectedColorType;
	NSTextView *_textView;
	NSDictionary *_constantColorsByName;
	
	NSRegularExpression *_rgbaUIColorRegex;
	NSRegularExpression *_rgbaNSColorRegex;
    NSRegularExpression *_rgbaSKColorRegex;
	NSRegularExpression *_whiteNSColorRegex;
	NSRegularExpression *_whiteUIColorRegex;
    NSRegularExpression *_whiteSKColorRegex;
	NSRegularExpression *_constantColorRegex;
}

@property (nonatomic, strong) OMPlainColorWell *colorWell;
@property (nonatomic, strong) OMColorFrameView *colorFrameView;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, assign) NSRange selectedColorRange;
@property (nonatomic, assign) OMColorType selectedColorType;

- (void)dismissColorWell;
- (void)activateColorHighlighting;
- (void)deactivateColorHighlighting;
- (NSColor *)colorInText:(NSString *)text selectedRange:(NSRange)selectedRange type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange;
- (NSString *)colorStringForColor:(NSColor *)color withType:(OMColorType)colorType;
- (double)dividedValue:(double)value withDivisorRange:(NSRange)divisorRange inString:(NSString *)text;

@end
