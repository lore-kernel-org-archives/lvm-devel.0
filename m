From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:15:38 -0000
Subject: LVM2/lib/device dev-io.c
Message-ID: <20120208111538.31158.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:15:38

Modified files:
	lib/device     : dev-io.c 

Log message:
	Move close few lines
	
	Since the function dev_close() has code path, which really could close
	file (for unlocked vg) and destroy dev handler, stay on safe side and move
	the close few lines later, even our current use case shouldn't trigger
	such scenario.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/lib/device/dev-io.c	2011/12/21 13:24:25	1.79
+++ LVM2/lib/device/dev-io.c	2012/02/08 11:15:38	1.80
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -292,15 +292,15 @@
 		return 0;
 	}
 
-	if (!dev_close(dev))
-		stack;
-
 	*read_ahead = (uint32_t) read_ahead_long;
 	dev->read_ahead = read_ahead_long;
 
 	log_very_verbose("%s: read_ahead is %u sectors",
 			 dev_name(dev), *read_ahead);
 
+	if (!dev_close(dev))
+		stack;
+
 	return 1;
 }
 


