/**
 * @file Object.h
 * @date 20-Feb-2021
 */

#ifndef __OBJECT_H__
#define __OBJECT_H__

#include "GamesProgramming.h"

/** Object Class
 */
class Object : public ScrollObject
{
public:


protected:

                void            OnCreate();
                void            OnDelete();
                void            Update(const orxCLOCK_INFO &_rstInfo);


private:
};

#endif // __OBJECT_H__
