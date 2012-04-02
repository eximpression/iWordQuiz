//
//  DetailViewController.m
//  iWordQuiz
//

/************************************************************************

Copyright 2012 Peter Hedlund peter.hedlund@me.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*************************************************************************/

#import "DetailViewController.h"
#import "RootViewController.h"
#import "DDXML.h"
#import "HomeViewController.h"
#import "FCViewController.h"
#import "MCViewController.h"
#import "QAViewController.h"
#import "AboutViewController.h"
#import "WordQuizAppDelegate.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize popoverController;
@synthesize modePicker, modePickerPopover;
@synthesize doc;


- (void) setDocument:(NSURL *)URL
{
	if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }

    [self.doc setUrl:URL];
    [self.doc load];
    
    if (m_quiz != nil) {
        [m_quiz release];
		m_quiz = nil;
	}
	
    m_quiz = [[iWQQuiz alloc] init];
	[m_quiz setEntries:[doc quizEntries]];
	[m_quiz setFrontIdentifier:[doc frontIdentifier]];
	[m_quiz setBackIdentifier:[doc backIdentifier]];
	[m_quiz setFileName:[[URL lastPathComponent] stringByDeletingPathExtension]];
	
	[self activateTab:self.selectedIndex];
	self.navigationItem.title = [[URL lastPathComponent] stringByDeletingPathExtension];
	//[URL release];
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}
 */

- (void)configureView {
    // Update the user interface for the detail item.
    //detailDescriptionLabel.text = [detailItem description];   
	//if (currentViewController == flashViewController) {
		//flashViewController.identifierLabel.text =  [detailItem description];
	//}
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = @"Vocabularies";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	for (UIViewController *myView in self.viewControllers) {
		[myView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
}



#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    doc = [[WQDocument alloc] init];

    NSMutableArray *listOfViewControllers = [[NSMutableArray alloc] init];
	HomeViewController *hvc;
    hvc = [[HomeViewController alloc] init];
    hvc.tabBarItem.image = [UIImage imageNamed:@"homeTab.png"];
	hvc.title = @"Home";
    
	[listOfViewControllers addObject:hvc];
	[hvc release];
    
    FCViewController *fcvc;
    fcvc = [[FCViewController alloc] init];
	fcvc.title = @"Flashcard";
    fcvc.tabBarItem.image = [UIImage imageNamed:@"flashTab.png"];
	[listOfViewControllers addObject:fcvc];
	[fcvc release];    
    
    MCViewController *mcvc;
    mcvc = [[MCViewController alloc] init];
	mcvc.title = @"Multiple Choice";
    mcvc.tabBarItem.image = [UIImage imageNamed:@"multipleTab.png"];
	[listOfViewControllers addObject:mcvc];
	[mcvc release]; 
    
    QAViewController *qavc;
    qavc = [[QAViewController alloc] init];
	qavc.title = @"Question & Answer";
    qavc.tabBarItem.image = [UIImage imageNamed:@"qaTab.png"];
	[listOfViewControllers addObject:qavc];
	[qavc release]; 
    
    [self setViewControllers:listOfViewControllers animated:YES];
    [listOfViewControllers release];
    
    UIBarButtonItem* button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(doAbout:)]; 
	//self.navigationItem.rightBarButtonItem = button;
    
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Mode" style:UIBarButtonItemStyleBordered target:self action:@selector(doMode:)]; 
	//self.navigationItem.rightBarButtonItem = button;
    NSArray *buttons = [NSArray arrayWithObjects:button1, button, nil];
    self.navigationItem.rightBarButtonItems = buttons;
	[button release];
    [button1 release];
    //[buttons release];

	[self activateTab:1];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.selectedViewController willRotateToInterfaceOrientation:[[UIDevice currentDevice] orientation ] duration:0];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}


- (void)activateTab:(int)index {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// getting an NSInteger
	NSInteger myMode = [prefs integerForKey:@"Mode"];
	if (myMode == 0) {
		myMode = 1;
	}
	if (m_quiz != nil) {
		m_quiz.quizMode = myMode;
        if (index == 0) {
            [self.selectedViewController setDoc:self.doc];
		    [self.selectedViewController restart];
        } else {
            [self.selectedViewController setQuiz:m_quiz];
		    [self.selectedViewController restart];
        }
		
	}
}


- (void)modeSelected:(NSUInteger)mode {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// saving an NSInteger
	[prefs setInteger:mode + 1 forKey:@"Mode"];
	[prefs synchronize];
	
	m_quiz.quizMode = mode + 1;
    [self.modePickerPopover dismissPopoverAnimated:YES];
	[self activateTab:self.selectedIndex];
}

- (NSUInteger)selectedMode {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// getting an NSInteger
	NSInteger myMode = [prefs integerForKey:@"Mode"];
	if (myMode == 0) {
		myMode = 1;
	}
	
	return myMode;
}

- (IBAction) doMode:(id)sender {
    if (modePicker == nil) {
        self.modePicker = [[[ModePickerController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        modePicker.delegate = self;
        self.modePickerPopover = [[[UIPopoverController alloc] initWithContentViewController:modePicker] autorelease];               
    }
    [self.modePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction) doAbout:(id)sender {
    // Create the modal view controller
	AboutViewController *aboutController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	
	// We are the delegate responsible for dismissing the modal view
	aboutController.delegate = ((iWordQuizAppDelegate *)[[UIApplication sharedApplication] delegate]);
	
	// Create a Navigation controller
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	// show the navigation controller modally
	[((iWordQuizAppDelegate *)[[UIApplication sharedApplication] delegate]).splitViewController presentModalViewController:navController animated:YES];
	
	// Clean up resources
	[navController release];
	[aboutController release];
}
- (void) quizDidFinish {
	//self.repeatErrors.enabled = [m_quiz hasErrors];
}

- (BOOL) hasQuiz {
    return m_quiz != nil;
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    [popoverController release];
	[modePicker release];
	[modePickerPopover release];
	
	[m_quiz release];
    [doc release];
	
    [super dealloc];
}

@end
