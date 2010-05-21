From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 13:34:11 -0000
Subject: LVM2/lib/metadata replicator_manip.c
Message-ID: <20100521133411.13004.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 13:34:10

Modified files:
	lib/metadata   : replicator_manip.c 

Log message:
	Add toolcontext.h header file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/metadata/replicator_manip.c	2010/05/21 12:55:25	1.4
+++ LVM2/lib/metadata/replicator_manip.c	2010/05/21 13:34:09	1.5
@@ -16,6 +16,7 @@
 #include "locking.h"
 #include "metadata.h"
 #include "segtype.h"
+#include "toolcontext.h"
 
 /* Add lv as replicator_dev device */
 int replicator_dev_add_rimage(struct replicator_device *rdev,


