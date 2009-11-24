From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Nov 2009 16:11:39 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20091124161139.22924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-24 16:11:38

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 

Log message:
	Move persistent filter dump to more appropriate place.
	
	After context_refresh is cache empty, the cache flush
	does nothing.
	
	Call it after lvmcache full rescan if running from
	log lived process.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1324&r2=1.1325
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/WHATS_NEW	2009/11/24 16:10:25	1.1324
+++ LVM2/WHATS_NEW	2009/11/24 16:11:37	1.1325
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Move persistent filter dump to more appropriate place.
   Refresh device filters before full device rescan in lvmcache.
   Return error status if vgchange fails to activate some volume.
   Fix memory lock imbalance in locking code.
--- LVM2/lib/cache/lvmcache.c	2009/11/24 16:10:25	1.72
+++ LVM2/lib/cache/lvmcache.c	2009/11/24 16:11:37	1.73
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "metadata.h"
 #include "filter.h"
+#include "filter-persistent.h"
 #include "memlock.h"
 #include "str_list.h"
 #include "format-text.h"
@@ -533,6 +534,13 @@
 			goto out;
 	}
 
+	/*
+	 * If we are a long-lived process, write out the updated persistent
+	 * device cache for the benefit of short-lived processes.
+	 */
+	if (full_scan == 2 && cmd->is_long_lived && cmd->dump_filter)
+		persistent_filter_dump(cmd->filter);
+
 	r = 1;
 
       out:
--- LVM2/lib/commands/toolcontext.c	2009/11/24 16:10:26	1.87
+++ LVM2/lib/commands/toolcontext.c	2009/11/24 16:11:38	1.88
@@ -1291,13 +1291,6 @@
 	if (!_init_segtypes(cmd))
 		return 0;
 
-	/*
-	 * If we are a long-lived process, write out the updated persistent
-	 * device cache for the benefit of short-lived processes.
-	 */
-	if (cmd->is_long_lived && cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
-
 	cmd->config_valid = 1;
 
 	reset_lvm_errno(1);


