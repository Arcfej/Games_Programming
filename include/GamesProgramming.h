/**
 * @file GamesProgramming.h
 * @date 20-Feb-2021
 */

#ifndef __GamesProgramming_H__
#define __GamesProgramming_H__

#define __NO_SCROLLED__
#include "Scroll.h"

/** Game Class
 */
class GamesProgramming : public Scroll<GamesProgramming>
{
public:


private:

                orxSTATUS       Bootstrap() const;

                void            Update(const orxCLOCK_INFO &Info);

                orxSTATUS       Init();
                orxSTATUS       Run();
                void            Exit();
                void            BindObjects();


private:
};

#endif // __GamesProgramming_H__
