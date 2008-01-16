From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jan 2008 17:14:57 -0000
Subject: LVM2 man/vgsplit.8 tools/commands.h tools/lvmc ...
Message-ID: <20080116171457.17751.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-16 17:14:56

Modified files:
	man            : vgsplit.8 
	tools          : commands.h lvmcmdline.c 

Log message:
	Remove unused 'list' param from vgsplit - conflict with maxlogicalvolumes param.
	Initialize lvm command getopt buffer to zero before building options string.
	Bugzilla: bz251992
	
	---
	man/vgsplit.8      |    3 +--
	tools/commands.h   |    3 +--
	tools/lvmcmdline.c |    1 +
	3 files changed, 3 insertions(+), 4 deletions(-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/man/vgsplit.8	2008/01/14 21:07:58	1.4
+++ LVM2/man/vgsplit.8	2008/01/16 17:14:56	1.5
@@ -9,8 +9,7 @@
 .RB [ \-c | \-\-clustered " {" y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
-.RB [ \-l | \-\-list ]
-.RB [ \-\-maxlogicalvolumes
+.RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
 .RB [ -M | \-\-metadatatype
 .IR type ]
--- LVM2/tools/commands.h	2008/01/14 21:07:58	1.106
+++ LVM2/tools/commands.h	2008/01/16 17:14:56	1.107
@@ -878,7 +878,6 @@
    "\t[-c|--clustered {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
-   "\t[-l|--list]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
@@ -889,7 +888,7 @@
    "\tSourceVolumeGroupName DestinationVolumeGroupName" "\n"
    "\tPhysicalVolumePath [PhysicalVolumePath...]\n",
 
-   alloc_ARG, autobackup_ARG, clustered_ARG, list_ARG,
+   alloc_ARG, autobackup_ARG, clustered_ARG,
    maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
    metadatatype_ARG, physicalextentsize_ARG, test_ARG)
 
--- LVM2/tools/lvmcmdline.c	2008/01/09 15:55:44	1.57
+++ LVM2/tools/lvmcmdline.c	2008/01/16 17:14:56	1.58
@@ -584,6 +584,7 @@
 		a->ui64_value = 0;
 	}
 
+	memset(str, 0, sizeof(str));
 	/* fill in the short and long opts */
 	for (i = 0; i < cmd->command->num_args; i++)
 		_add_getopt_arg(cmd->command->valid_args[i], &ptr, &o);


