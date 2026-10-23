#import "SKLocalization.h"

NSString * const SKLanguageDidChangeNotification =
    @"SKLanguageDidChangeNotification";

NSString *SKCurrentLanguageCode(void)
{
    NSString *saved =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"SKLanguage"];

    if (saved && [saved length])
        return saved;

    NSArray *languages = [NSLocale preferredLanguages];

    if ([languages count] > 0) {
        NSString *language = [languages objectAtIndex:0];

        if ([language hasPrefix:@"en"])
            return @"en";
    }

    return @"ru";
}

void SKSetLanguageCode(NSString *code)
{
    if (![code isEqualToString:@"en"] &&
        ![code isEqualToString:@"ru"])
        code = @"ru";

    [[NSUserDefaults standardUserDefaults]
        setObject:code
        forKey:@"SKLanguage"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SKLanguageDidChangeNotification
        object:nil];
}

BOOL SKIsEnglish(void)
{
    return [SKCurrentLanguageCode() isEqualToString:@"en"];
}

NSString *SKLocalized(NSString *value)
{
    if (!value || !SKIsEnglish())
        return value;

    static NSDictionary *translations = nil;

    if (!translations) {
        translations = [[NSDictionary alloc]
            initWithObjectsAndKeys:
            @"Skednya Maps", @"скеднЯ Карты",
            @"Find a place or address", @"Найти место или адрес",
            @"Searching...", @"Ищу...",
            @"My Location", @"Где я",
            @"Schedule", @"Расписание",
            @"Settings", @"Настройки",
            @"Language", @"Язык",
            @"Choose language", @"Выберите язык",
            @"Latitude: %.6f\nLongitude: %.6f",
                @"Широта: %.6f\nДолгота: %.6f",
            @"Location", @"Местоположение",
            @"Show airplanes", @"Показывать самолёты",
            @"Show buses", @"Показывать автобусы",
            @"Routes: %@", @"Маршруты: %@",
            @"Routes unavailable", @"Маршруты не указаны",
            @"Stop", @"Остановка",
            @"Restaurant", @"Ресторан",
            @"Cuisine: %@", @"Кухня: %@",
            @"Route #%@", @"Маршрут №%@",
            @"Nothing found", @"ничего не найдено",
            @"Cancel", @"Отмена",
            nil];
    }

    NSString *translated = [translations objectForKey:value];

    return translated ? translated : value;
}
