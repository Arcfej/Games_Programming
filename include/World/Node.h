#ifndef NODE_H
#define NODE_H

#include "Object.h"

struct Node : Object
{

    orxLINKLIST neighbors;
};

#endif
