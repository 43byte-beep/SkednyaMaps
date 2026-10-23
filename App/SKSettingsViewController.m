#import "SKSettingsViewController.h"
#import "SKLocalization.h"

@interface SKSettingsViewController () <UIActionSheetDelegate>
@end

NSString * const SKSettingsChangedNotification =
    @"SKSettingsChangedNotification";

static NSString * const SKShowAirplanesKey =
    @"SKShowAirplanes";

static NSString * const SKShowBusesKey =
    @"SKShowBuses";

@implementation SKSettingsViewController

+ (BOOL)showsAirplanes
{
    return NO;
}

+ (BOOL)showsBuses
{
    return NO;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self)
        self.title = SKL(@"Настройки");

    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;

    if (indexPath.row == 0)
        identifier = @"LanguageCell";
    else
        identifier = @"SettingsCell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        UITableViewCellStyle style =
            (indexPath.row == 0)
                ? UITableViewCellStyleValue1
                : UITableViewCellStyleDefault;

        cell =
            [[[UITableViewCell alloc]
                initWithStyle:style
                reuseIdentifier:identifier]
                autorelease];
    }

    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (indexPath.row == 0) {

        cell.textLabel.text = SKL(@"Язык");
        cell.detailTextLabel.text =
            SKIsEnglish() ? @"English" : @"Русский";

        cell.accessoryType =
            UITableViewCellAccessoryDisclosureIndicator;

    } else if (indexPath.row == 1) {

        cell.textLabel.text =
            SKL(@"Показывать самолёты");

        UISwitch *toggle =
            [[[UISwitch alloc] initWithFrame:CGRectZero]
                autorelease];

        toggle.tag = 1;
        toggle.on =
            [SKSettingsViewController showsAirplanes];

        [toggle addTarget:self
                   action:@selector(settingChanged:)
         forControlEvents:UIControlEventValueChanged];

        cell.accessoryView = toggle;

    } else {

        cell.textLabel.text =
            SKL(@"Показывать автобусы");

        UISwitch *toggle =
            [[[UISwitch alloc] initWithFrame:CGRectZero]
                autorelease];

        toggle.tag = 2;
        toggle.on =
            [SKSettingsViewController showsBuses];

        [toggle addTarget:self
                   action:@selector(settingChanged:)
         forControlEvents:UIControlEventValueChanged];

        cell.accessoryView = toggle;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0)
        [self sk_showLanguagePicker];
}

- (void)settingChanged:(UISwitch *)sender
{
    NSUserDefaults *d =
        [NSUserDefaults standardUserDefaults];

    if (sender.tag == 1) {
        [d setBool:sender.on forKey:SKShowAirplanesKey];
    } else if (sender.tag == 2) {
        [d setBool:sender.on forKey:SKShowBusesKey];
    }

    [d synchronize];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKSettingsChangedNotification
        object:nil];
}

- (void)sk_showLanguagePicker
{
    UIActionSheet *sheet =
        [[[UIActionSheet alloc]
            initWithTitle:SKL(@"Выберите язык")
            delegate:self
            cancelButtonTitle:SKL(@"Отмена")
            destructiveButtonTitle:nil
            otherButtonTitles:@"Русский", @"English", nil]
            autorelease];

    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        SKSetLanguageCode(@"ru");
    } else if (buttonIndex == 1) {
        SKSetLanguageCode(@"en");
    } else {
        return;
    }

    self.title = SKL(@"Настройки");
    [self.tableView reloadData];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKSettingsChangedNotification
        object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = SKL(@"Настройки");
    [self.tableView reloadData];
}

- (void)dismissSettings
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
