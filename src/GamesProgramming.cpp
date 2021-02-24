/**
 * @file GamesProgramming.cpp
 * @date 20-Feb-2021
 */

#define __SCROLL_IMPL__
#include "GamesProgramming.h"
#undef __SCROLL_IMPL__

#define orxNUKLEAR_IMPL
#include "orxNuklear.h"
#undef orxNUKLEAR_IMPL

/** Update function, it has been registered to be called every tick of the core clock
 */
void GamesProgramming::Update(const orxCLOCK_INFO &_rstInfo)
{
    // Should quit?
    if(orxInput_IsActive("Quit"))
    {
        // Send close event
        orxEvent_SendShort(orxEVENT_TYPE_SYSTEM, orxSYSTEM_EVENT_CLOSE);
    }
}

/** Init function, it is called when all orx's modules have been initialized
 */
orxSTATUS GamesProgramming::Init()
{
    // Display a small hint in console
    orxLOG("\n* This template project creates a simple scene"
    "\n* You can play with the config parameters in ../data/config/GamesProgramming.ini"
    "\n* After changing them, relaunch the executable to see the changes.");

    // Display additional Nuklear hint in console
    orxLOG("\n* This template has support for Nuklear.");

    // Initialize Dear ImGui
    orxNuklear_Init();

    // Create the scene
    CreateObject("Scene");

    // Done!
    return orxSTATUS_SUCCESS;
}

/** Run function, it should not contain any game logic
 */
orxSTATUS GamesProgramming::Run()
{
    // Return orxSTATUS_FAILURE to instruct orx to quit
    return orxSTATUS_SUCCESS;
}

/** Exit function, it is called before exiting from orx
 */
void GamesProgramming::Exit()
{
    // Exits from Nuklear
    orxNuklear_Exit();

    // Let Orx clean all our mess automatically. :)
}

/** BindObjects function, ScrollObject-derived classes are bound to config sections here
 */
void GamesProgramming::BindObjects()
{
    
}

/** Bootstrap function, it is called before config is initialized, allowing for early resource storage definitions
 */
orxSTATUS GamesProgramming::Bootstrap() const
{
    // Add a config storage to find the initial config file
    orxResource_AddStorage(orxCONFIG_KZ_RESOURCE_GROUP, "../data/config", orxFALSE);

    // Return orxSTATUS_FAILURE to prevent orx from loading the default config file
    return orxSTATUS_SUCCESS;
}

/** Main function
 */
int main(int argc, char **argv)
{
    // Execute our game
    GamesProgramming::GetInstance().Execute(argc, argv);

    // Done!
    return EXIT_SUCCESS;
}
