@import "SCSocket.j"
@import "Widget.j"

@implementation Canvas : CPView
{
    CGPoint dragStart;
    Widget currentWidget;
    Class drawClass;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self)
    {
        drawClass = RectWidget;
    }
    return self;
}

- (void)addWidget:(Widget)aWidget
{
    [self addSubview:aWidget];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(CPEvent)anEvent
{
    if ([anEvent characters] == "c")
        drawClass = CircleWidget;
    else if ([anEvent characters] == "r")
        drawClass = RectWidget;
}

- (void)mouseDown:(CPEvent)anEvent
{
    dragStart = [anEvent locationInWindow];
    var widget = [[drawClass alloc] initWithFrame:CGRectMake(dragStart.x, dragStart.y, 0, 0)];
    currentWidget = widget;
    [self addSubview:widget];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    if (currentWidget)
    {
        mouseLoc = [anEvent locationInWindow];
        var newWidth = mouseLoc.x - dragStart.x,
            newHeight = mouseLoc.y - dragStart.y,
            newX = dragStart.x,
            newY = dragStart.y;
        if (newWidth < 0)
            newX = dragStart.x + newWidth;
        if (newHeight < 0)
            newY = dragStart.y + newHeight;
        [currentWidget setFrame:CGRectMake(newX, newY, Math.abs(newWidth), Math.abs(newHeight))];
    }
}

- (Widget)widgetByJSObject:(JSObject)jsWidget
{
    var widgets = [self subviews],
        count = [widgets count];
    while (count--)
    {
        if ([widgets[count] isEqualToJSONWidget:jsWidget])
            return widgets[count];
    }
    return nil;
}

- (void)mouseUp:(CPEvent)anEvent
{
    if (currentWidget)
    {
        [[SCSocket sharedSocket] sendMessage:{'action' : 'add', 'widget' : [currentWidget toJSON]}];
        currentWidget = nil;
    }
}
@end
