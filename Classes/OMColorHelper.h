
//  OMColorHelper.h  OMColorHelper Created by Ole Zorn on 09/07/12.

@import AppKit;

typedef NS_ENUM(int, OMColorType) {

	OMColorTypeNone = 0,
	
	OMColorTypeUIRGBA,            //  [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeUIRGBAInit,        //  [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeUIWhite,           //  [UIColor colorWithWhite:0.5 alpha:1.0]
	OMColorTypeUIWhiteInit,       //  [[UIColor alloc] initWithWhite:0.5 alpha:1.0]
	OMColorTypeUIConstant,        //  [UIColor redColor]
	
	OMColorTypeNSRGBACalibrated,	//  [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeNSRGBADevice,      //  [NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0]
	OMColorTypeNSWhiteCalibrated,	//  [NSColor colorWithCalibratedWhite:0.5 alpha:1.0]
	OMColorTypeNSWhiteDevice,     //  [NSColor colorWithDeviceWhite:0.5 alpha:1.0]
	OMColorTypeNSConstant,        //  [NSColor redColor]
	OMColorType6DigitHex,         //  #ffffff
  OMColorType3DigitHex          //  #fff

};

BOOL OMColorTypeIsNSColor(OMColorType colorType) { return colorType >= OMColorTypeNSRGBACalibrated; }

//TODO: Maybe support HSB and CMYK color types...

@class                OMColorFrameView ,
                      OMPlainColorWell ;

@interface               OMColorHelper : NSObject

@property (nonatomic) OMPlainColorWell * colorWell;
@property (nonatomic) OMColorFrameView * colorFrameView;
@property (nonatomic)       NSTextView * textView;
@property (nonatomic)          NSRange   selectedColorRange;
@property (nonatomic)      OMColorType   selectedColorType;

- (void) dismissColorWell;
- (void) activateColorHighlighting;
- (void) deactivateColorHighlighting;

- (NSColor*) colorInText:(NSString*)x selectedRange:(NSRange)r
                 type:(OMColorType*)t matchedRange:(NSRangePointer)m;

- (NSString*) colorStringForColor:(NSColor*)c withType:(OMColorType)t;

- (double) dividedValue:(double)v withDivisorRange:(NSRange)r inString:(NSString *)text;

@end
