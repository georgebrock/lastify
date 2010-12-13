/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSUndoManager.h"

@interface SPUndoManager : NSUndoManager
{
    id _undo_target;
    id _redo_target;
    SEL _undo_sel;
    SEL _redo_sel;
    id _undo_object;
    id _redo_object;
}

- (id)init;
- (void)undo;
- (void)redo;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (id)undoMenuItemTitle;
- (id)redoMenuItemTitle;
- (void)registerUndoTarget:(id)fp8 selector:(SEL)fp12 withObject:(id)fp16;
- (void)registerRedoTarget:(id)fp8 selector:(SEL)fp12 withObject:(id)fp16;

@end

