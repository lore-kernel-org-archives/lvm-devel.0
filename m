From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2011 15:15:38 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in tools/args. ...
Message-ID: <20110817151538.32639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-17 15:15:37

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in 
	tools          : args.h commands.h 

Log message:
	Add -V as short form of --virtualsize in lvcreate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2073&r2=1.2074
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.159&r2=1.160

--- LVM2/WHATS_NEW	2011/08/12 13:03:35	1.2073
+++ LVM2/WHATS_NEW	2011/08/17 15:15:36	1.2074
@@ -1,5 +1,6 @@
 Version 2.02.88 - 
 ==================================
+  Add -V as short form of --virtualsize in lvcreate.
   Fix make clean not to remove Makefile.  (2.02.87)
 
 Version 2.02.87 - 12th August 2011
--- LVM2/man/lvcreate.8.in	2011/08/02 22:07:23	1.20
+++ LVM2/man/lvcreate.8.in	2011/08/17 15:15:37	1.21
@@ -36,7 +36,7 @@
 {{\-s|\-\-snapshot}
 OriginalLogicalVolumePath | 
 [\-s|\-\-snapshot]
-VolumeGroupName \-\-virtualsize VirtualSize}
+VolumeGroupName \-V|\-\-virtualsize VirtualSize}
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
@@ -205,7 +205,7 @@
 commandline switch alias is available for the desired type, as is the case
 with "error", "zero", "raid4", "raid5", or "raid6".
 .TP
-.I \-\-virtualsize VirtualSize
+.I -V, \-\-virtualsize VirtualSize
 Create a sparse device of the given size (in MB by default) using a snapshot.  
 Anything written to the device will be returned when reading from it.
 Reading from other areas of the device will return blocks of zeros.
--- LVM2/tools/args.h	2010/11/11 17:29:06	1.81
+++ LVM2/tools/args.h	2011/08/17 15:15:37	1.82
@@ -66,7 +66,6 @@
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
-arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
@@ -139,6 +138,7 @@
 arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0)
 arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE)
 arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0)
+arg(virtualsize_ARG, 'V', "virtualsize", size_mb_arg, 0)
 arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0)
 arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0)
 arg(yes_ARG, 'y', "yes", NULL, 0)
--- LVM2/tools/commands.h	2011/08/04 10:12:44	1.159
+++ LVM2/tools/commands.h	2011/08/17 15:15:37	1.160
@@ -175,7 +175,7 @@
 
    "lvcreate \n"
    "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
-   "\t  [-s|--snapshot] VolumeGroupName[Path] --virtualsize VirtualSize}\n"
+   "\t  [-s|--snapshot] VolumeGroupName[Path] -V|--virtualsize VirtualSize}\n"
    "\t[-c|--chunksize]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"


