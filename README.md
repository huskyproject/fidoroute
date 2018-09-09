# fidoroute
[![Build Status](https://travis-ci.org/huskyproject/fidoroute.svg?branch=master)](https://travis-ci.org/huskyproject/fidoroute)
[![Build status](https://ci.appveyor.com/api/projects/status/nqakeew8dax0q4ps/branch/master?svg=true)](https://ci.appveyor.com/project/dukelsky/fidoroute/branch/master)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a3c20b32b80442a7955f7563fb24981a)](https://www.codacy.com/app/huskyproject/fidoroute?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=huskyproject/fidoroute&amp;utm_campaign=Badge_Grade)

**Fidoroute** is a Fidonet node route file generator

## NAME

**fidoroute** - fidonet node route file generator

## SYNTAX
       fidoroute [config.file]

If   config.file   is   not  specified,  then  fidoroute  looks  for  a
"fidoroute.conf" in the current directory.

## DESCRIPTION
Fidoroute uses a configuration file named **fidoroute.conf** . This configuration file will be looked for in the current directory  unless  specified at the command line.

Configuration file contains statements in the form:

       token value

Empty lines are ignored. Lines  beginning  with '#' or ';' characters are also ignored (they are comment lines).

## PARAMETERS

**Address** \<FTN address of your node\>

Each 'Address' line contains FTN address or AKA of your node in the 3D form. No 4D address (point AKA) should be specified here.

Example:

       Address 2:5020/204
       Address 7:1130/204
       
Examples of wrong syntax:

       Address 2:5020/204.1
       Address 7:1130/0@fidorus

**Hubroute** \<nodelist file\> \<type of nodelist\> \<zone number\> \<net number\>

where:

- \<nodelist file\> - pathname of the world nodelist or nodelist segment file; it may use '?' and '\*' shell wildcard characters;

- \<type of nodelist\> - 'z' for the zone/world nodelist, 'r' for  the regional segment, 'n' for the network segment;

- \<zone number\> - zone number for the routing;

- \<net number\> - net number for the routing.
       
Every Hubroute line tells router to get hub- and host- routing information from nodelist or nodelist segment. If nodelist file name is wildcarded and there are several matching files, router will take the file with bigger suffix (i.e. bigger day number).

Examples:

       Hubroute /fido/nodelist/nodelist.* z 2 5020
       Hubroute /fido/nodelist/z2-list.* z 2 5020
       Hubroute /fido/nodelist/net5020.ndl n 2 5020


**RouteFile** \<.ROU file\>

where:

- \<.ROU file\> - pathname of the .ROU file.

A .ROU file has format:  
```
next_hop destination \[destination ...\] next_hop "World"
```
Where *next_hop* is the node where netmail for destination nodes, networks and zones should be routed to. Wildcards like        '2:5020/545.\*' or '2:5020/545.All' are allowed in destinations. Special token "World" means "all other destinations" and  should              be the last in the list.

Example:

              2:5020/888  999 555 5030/444 3:All/All
              2:5020/50   World

**TrustFile** \<.TRU file\>

where:

- \<.TRU file\> - pathname of the .TRU file.

A .TRU file has the same format as a .ROU file.

**DefaultRoute** \<route_to\> \<destination\>

This line gives you a possibility to override some route branches without creating additional .ROU file. Syntax is the             same as in a routefile. *DefaultRoute* is treated AFTER all other lines, so it have the highest priority.

**WriteTo** \<route file pathname\>
  
- \<route file pathname\> is the output file (the routing file for your tracker).

**RouteType** \<type of route file\>

- \<type of route file\> specifies routing file syntax. It should be one of: *husky* (for  hpt), *squish*,  *tmail* (for the T-mail version before v.2601),           *tmailn* (for the T-mail version v.2601 and above), *itrack*, *bpack*, *imbink*, *xmail*, *ifmail*, *unimail*, *bip*, *fidogate*, *qecho*, *ftrack*.

**Minimize** \<switch\>

- \<switch\> may be *on*, *yes* or *off*, *no*. Set it to *on* or *yes* for routing minimization.

**RouteBegin** \<signature1\>

**RouteEnd** \<signature2\>

These *signature*s are used to specify the start and the end of rewritable area in the route file. It is recommended to enclose both *signature*s into double-quotes ("). Be careful! Everything between these two signatures will be deleted from the route file. Do not forget to add these strings to route file before running fidoroute.

**Link** \<FTN address\> \<flavors\>

where:

- \<FTN address\> is the FTN address of the your (direct) link;

- \<flavors\> may be one of the characters: 'C' (crash), 'D' (direct), 'N' (normal) or 'H' (hold) with combination of 'F' (route files) and 'A' (no arcmail),

BNF:

flavors := {'C'|'D'|'N'|'H'}\['F'\]\['A'\]

Examples:

              Link 2:5020/0  CFA
              Link 2:5020/24 DF

**DefaultFlavor** \<flavors\>

This statement sets default flavor for links, which are not present in 'Link' lines, but must be routed via us. If the DefaultRoute is missing in config file, 'Hold' is assumed. See flavors description in the *Link* statement.

**TempFile** \</path/file.tm\p>

This statement defines temporary file for building WriteTo file. *TempFile* and *WriteTo* file are required to be placed on the same disk volume. Default value of *TempFile* is *WriteTo* with '$$$' suffix, and if you don't specify *Tempfile*, you should make directory for *WriteTo* file writable by the user running fidoroute.

## Limitation and hints

Maximum number of 'routing items' (i.e. nodes, nets, zones) is 5000. It can be increased at compile time, but I cannot imagine node which needs that.

Maximum number of recursively linked branches - about 600 (it is not the maximum number of routing branches but the number of sequentaly linked branches, i.e. the number of hops to destination node). Enough, IMHO. :)

Maximum number of direct links is 1000. If you have more - just increase and recompile.

Maximum number of local addresses is 50.

Maximum length of deadloop routing chain is unlimited.

Maximum length of go-round routing chain is unlimited. If router detects such a chain, it will try to carefully mark unliked node as warned, of course. Usually router does this in a reasonable manner, but you should check it.

When re-routing has occured, router prints messages. The last re-routing is used. Example:

       2:5020/50 22
       2:5020/52 22

There will be a re-routing warning, mail for /22 will go via /52.

Warning! In this case:

       2:5020/24  469/All
       2:5020/777 469/83

there is no routing conflict. 469/83's mail will go to 5020/777,  other NET469's mail will be routed via 5020/24.
