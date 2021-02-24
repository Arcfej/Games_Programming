#ifndef SWITCH_H
#define SWITCH_H

#include "Object.h"

class Switch :
    public Object
{
    orxLINKLIST disconnectibles;

public:
    void change();
};

#endif
