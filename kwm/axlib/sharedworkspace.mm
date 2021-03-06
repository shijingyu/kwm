#import <Cocoa/Cocoa.h>
#import "sharedworkspace.h"

#define internal static
#define local_persist static

internal std::map<pid_t, ax_application> *Applications;

void SharedWorkspaceSetApplicationsPointer(std::map<pid_t, ax_application> *Apps)
{
    Applications = Apps;
}

std::map<pid_t, std::string> SharedWorkspaceRunningApplications()
{
    std::map<pid_t, std::string> List;

    for(NSRunningApplication *Application in [[NSWorkspace sharedWorkspace] runningApplications])
    {
        pid_t PID = Application.processIdentifier;

        std::string Name = "[Unknown]";
        const char *NamePtr = [[Application localizedName] UTF8String];
        if(NamePtr)
            Name = NamePtr;

        List[PID] = Name;
    }

    return List;
}

void SharedWorkspaceDidLaunchApplication(pid_t PID, std::string Name)
{
    (*Applications)[PID] = AXLibConstructApplication(PID, Name);
}

void SharedWorkspaceDidTerminateApplication(pid_t PID)
{
    std::map<pid_t, ax_application>::iterator It = Applications->find(PID);
    if(It != Applications->end())
    {
        AXLibDestroyApplication(&It->second);
        Applications->erase(PID);
    }
}

void SharedWorkspaceActivateApplication(pid_t PID)
{
    NSRunningApplication *Application = [NSRunningApplication runningApplicationWithProcessIdentifier:PID];
    if(Application)
        [Application activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

bool SharedWorkspaceIsApplicationActive(pid_t PID)
{
    Boolean Result = NO;
    NSRunningApplication *Application = [NSRunningApplication runningApplicationWithProcessIdentifier:PID];
    if(Application)
        Result = [Application isActive];

    return Result == YES;
}
