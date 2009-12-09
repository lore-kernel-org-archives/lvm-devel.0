From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:30:57 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20091209193057.24840.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:30:56

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix missing include.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:01:28	1.77
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:30:56	1.78
@@ -52,6 +52,7 @@
 #include "locking.h"
 #include "archiver.h"
 #include "defaults.h"
+#include "memlock.h"
 
 static struct cmd_context *cmd = NULL;
 static struct dm_hash_table *lv_hash = NULL;


