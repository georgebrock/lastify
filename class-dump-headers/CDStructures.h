/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

@class SPAutocompleteMenuWindow;

struct $_2265 {
    struct TrackInfo *_field1;
    unsigned int _field2;
    struct TrackInfo *_field3;
    char *_field4;
};

struct AdQueueEntry;

struct AlbumInfo;

struct Array<sp::AutocompleteDelegate::Completion, const sp::AutocompleteDelegate::Completion&, 64, true> {
    struct Completion *_mem;
    unsigned int _alloc;
    unsigned int _count;
};

struct Array<sp::MetadataEditor::TrackData, const sp::MetadataEditor::TrackData&, 64, true> {
    struct TrackData *_field1;
    unsigned int _field2;
    unsigned int _field3;
};

struct Array<sp::MetadataParser*, sp::MetadataParser* const&, 64, true> {
    struct MetadataParser **_field1;
    unsigned int _field2;
    unsigned int _field3;
};

struct ArtistInfo;

struct AudioDeviceListenerOSX;

struct AutocompleteDelegate {
    void **_field1;
};

struct CGImage;

struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(), void (*)(), void (*)()> {
    struct GenericClass *_field1;
    struct {
        int *_field1;
    } _field2;
};

struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(bool, const sp::String&), void (*)(bool, const sp::String&), void (*)(bool, const sp::String&)> {
    struct GenericClass *_field1;
    struct {
        int *_field1;
    } _field2;
};

struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(const sp::AutocompleteDelegate::Completion&), void (*)(const sp::AutocompleteDelegate::Completion&), void (*)(const sp::AutocompleteDelegate::Completion&)> {
    struct GenericClass *_field1;
    struct {
        int *_field1;
    } _field2;
};

struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(unsigned int), void (*)(unsigned int), void (*)(unsigned int)> {
    struct GenericClass *_field1;
    struct {
        int *_field1;
    } _field2;
};

struct Completion {
    struct String _field1;
    struct String _field2;
    int _field3;
    _Bool _field4;
    struct FastDelegate1<const sp::AutocompleteDelegate::Completion&, void> _field5;
};

struct Delegate;

struct FastDelegate0<void> {
    struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(), void (*)(), void (*)()> _field1;
};

struct FastDelegate1<const sp::AutocompleteDelegate::Completion&, void> {
    struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(const sp::AutocompleteDelegate::Completion&), void (*)(const sp::AutocompleteDelegate::Completion&), void (*)(const sp::AutocompleteDelegate::Completion&)> _field1;
};

struct FastDelegate1<unsigned int, void> {
    struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(unsigned int), void (*)(unsigned int), void (*)(unsigned int)> _field1;
};

struct FastDelegate2<bool, const sp::String&, void> {
    struct ClosurePtr<void (fastdelegate::detail::GenericClass::*)(bool, const sp::String&), void (*)(bool, const sp::String&), void (*)(bool, const sp::String&)> _field1;
};

struct FileId {
    unsigned char _field1[20];
};

struct GenericClass;

struct GuiManager;

struct IGenericView;

struct IPopupMenu {
    void **_field1;
};

struct MetadataEditor {
    int _field1;
    int _field2;
    struct Array<sp::MetadataEditor::TrackData, const sp::MetadataEditor::TrackData&, 64, true> _field3;
    struct String _field4[18];
    _Bool _field5[18];
    int _field6[18];
    struct Array<sp::MetadataParser*, sp::MetadataParser* const&, 64, true> _field7;
    struct FastDelegate2<bool, const sp::String&, void> _field8;
    struct FastDelegate0<void> _field9;
    struct String _field10;
    _Bool _field11;
    int _field12;
};

struct MetadataEditorWindowDelegate {
    void **_field1;
};

struct MetadataParser;

struct OpaqueMenuRef;

struct OsAlias;

struct PlatformEditBox {
    void **_field1;
};

struct PlatformEditBoxOSX {
    void **_field1;
    id _field2;
    id _field3;
    id _field4;
    id _field5;
    id _field6;
    id _field7;
    id _field8;
    struct Delegate *_field9;
    struct AutocompleteDelegate *_field10;
    unsigned int _field11;
    struct Rect _field12;
    struct Rect _field13;
    _Bool _field14;
    _Bool _field15;
    _Bool _field16;
    _Bool _field17;
    _Bool _field18;
    _Bool _field19;
    _Bool _field20;
    _Bool _field21;
    _Bool _field22;
    struct String _field23;
    struct String _field24;
    int _field25;
};

struct PopupMenuOSX {
    void **_field1;
    id _field2;
    _Bool _field3;
};

struct PurchaseLinks;

struct Rect {
    int left;
    int top;
    int right;
    int bottom;
};

struct RefPtr<sp::AlbumInfo> {
    struct AlbumInfo *_field1;
};

struct RefPtr<sp::ArtistInfo> {
    struct ArtistInfo *_field1;
};

struct SPACMWWrap {
    SPAutocompleteMenuWindow *objc;
};

struct SkinManager;

struct StrPtrStruct;

struct String {
    union $_2215 ;
};

struct TrackData;

struct TrackId {
    unsigned char _field1[16];
};

struct TrackInfo {
    void **_field1;
    int _field2;
    char *_field3;
    unsigned int _field4;
    struct RefPtr<sp::AlbumInfo> _field5;
    struct RefPtr<sp::ArtistInfo> _field6;
    unsigned char _field7;
    unsigned char _field8;
    unsigned char _field9;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :3;
    unsigned int :2;
    unsigned int :1;
    unsigned int :1;
    unsigned int :3;
    unsigned int :1;
    unsigned int :2;
    unsigned int :2;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned int :1;
    unsigned char _field10;
    struct TrackInfo *_field11;
    struct VersionAndExpiry _field12;
    int _field13;
    struct TrackRelation *_field14;
    struct TrackInfo *_field15;
    struct TrackInfo *_field16;
    struct ArtistInfo **_field17;
    struct FileId _field18[2];
    union $_2264 _field19;
    union $_2266 _field20;
    struct OsAlias *_field21;
};

struct TrackRelation;

struct UserPasswordVerifier {
    void **_field1;
};

struct VersionAndExpiry {
    unsigned int _field1;
    unsigned int _field2;
};

struct WebBrowserNotifications;

struct WebBrowserOSX {
    void **_field1;
    id _field2;
    id _field3;
    id _field4;
    struct WebBrowserNotifications *_field5;
};

struct WindowControllerOSX {
    void **_field1;
    void **_field2;
    struct GuiManager *_field3;
    struct WindowSettings _field4;
    struct IGenericView *_field5;
    int _field6;
    struct String _field7;
    struct String _field8;
    _Bool _field9;
    struct String _field10;
    struct SkinManager *_field11;
    struct String _field12;
    unsigned int _field13;
    void **_field14;
    id _field15;
    _Bool _field16;
    id _field17;
    id _field18;
    struct AudioDeviceListenerOSX *_field19;
};

struct WindowSettings {
    struct Rect _field1;
    int _field2;
};

struct _NSPoint {
    float x;
    float y;
};

struct _NSRect {
    struct _NSPoint origin;
    struct _NSSize size;
};

struct _NSSize {
    float width;
    float height;
};

struct _NSZone;

struct __SCNetworkReachability;

struct in_addr {
    unsigned int _field1;
};

struct sockaddr_in {
    unsigned char _field1;
    unsigned char _field2;
    unsigned short _field3;
    struct in_addr _field4;
    char _field5[8];
};

typedef struct {
    int *_field1;
} CDAnonymousStruct1;

union $_2215 {
    char *t;
    struct StrPtrStruct *_d;
};

union $_2264 {
    struct TrackId _field1;
    struct $_2265 _field2;
};

union $_2266 {
    struct PurchaseLinks *_field1;
    char *_field2;
    struct AdQueueEntry *_field3;
};

