CONST IDRESOURCE         = 1
CONST IDMEXIT            = 5
CONST IDMARC             = 10
CONST IDMLINE            = 20
CONST IDMAREA            = 30
CONST IDMMARK            = 40
CONST IDMBIT             = 60

DECLARE FUNCTION GpiErase%( BYVAL HPS AS LONG )

DECLARE SUB DemoGpiPointArc(hps&,mode%)
DECLARE SUB DemoGpiFullArc(hps&,mode%)
DECLARE SUB DemoGpiPolyFilletSharp(hps&,mode%)
DECLARE SUB DemoGpiPolyFillet(hps&,mode%)
DECLARE SUB DemoGpiPolySpline(hps&,mode%)
DECLARE SUB DemoGpiPartialArc(hps&,mode%)
DECLARE SUB DemoLine(hwnd&)
DECLARE SUB DemoPatterns(hps&)
DECLARE SUB DemoBeginEndArea(hwnd&, hps&, lastgpi%, dclicked%)
DECLARE SUB DemoMark(hps&,lastgpi%)
DECLARE SUB Demo1PlaneBitmap(hps&)
DECLARE SUB Demo4PlaneBitmap(hps&)
DECLARE SUB DemoSystemBitmaps(hps&, lastgpi%)
DECLARE SUB DemoResizeBitmap(hwnd&, hps&)
DECLARE SUB DemoFillWithBitmap(hps&)
DECLARE SUB DemoCaptureAndMagnify(hab&, hwndFrame&, hwnd&, hps&)

DECLARE SUB DoYouReallyWantToQuit(hwnd&)
DECLARE FUNCTION MakeFixed&(realnum#)
DECLARE FUNCTION DisplayMessageBox%(message$, caption$)
DECLARE SUB DisplayChoice(hwnd&, hps&)

COMMON /Gdemo/ cxClient%, cyClient%

