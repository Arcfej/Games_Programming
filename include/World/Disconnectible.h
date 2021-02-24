#ifndef DISCONNECTIBLE_H
#define DISCONNECTIBLE_H

#include "Node.h"
#include "Object.h"

class Disconnectible :
    public Object
{
    Node from;
    Node to;
    orxBOOL isOpen;

public:
    virtual orxBOOL IsOpen()    = 0;
    virtual orxBOOL Change()    = 0;
    virtual void    Open()      = 0;
    virtual void    Close()     = 0;
};

#endif
