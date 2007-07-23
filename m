From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Jul 2007 10:41:19 -0000
Subject: LVM2/lib/misc util.c
Message-ID: <20070723104119.6688.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-07-23 10:41:19

Modified files:
	lib/misc       : util.c 

Log message:
	Fix compilation warning in util.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/misc/util.c	2007/07/20 15:48:39	1.1
+++ LVM2/lib/misc/util.c	2007/07/23 10:41:19	1.2
@@ -16,6 +16,9 @@
  * Return the address of the last file name component of NAME.
  * If NAME ends in a slash, return the empty string.
  */
+
+#include "lib.h"
+
 char *last_path_component(char const *name)
 {
 	char const *slash = strrchr (name, '/');


