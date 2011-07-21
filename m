From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Jul 2011 13:23:50 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20110721132350.5797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-07-21 13:23:49

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Compare also file size to detect changed config file
	
	Clvmd detects modifed config file before it takes lv_lock.
	If the config file is changed rapidly - the change was ignored within
	a seocnd ranged.  This patch adds also compare of file size.
	So change like some flag for 0 to 1 would pass unnoticed - but
	it's quick fix for failing test suite.
	
	FIXME: Implement inotify solution.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2042&r2=1.2043
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2011/07/08 19:57:33	1.2042
+++ LVM2/WHATS_NEW	2011/07/21 13:23:48	1.2043
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Compare also file size to detect changed config file.
 
 Version 2.02.86 - 8th July 2011
 ===============================
--- LVM2/lib/config/config.c	2011/07/19 19:12:38	1.100
+++ LVM2/lib/config/config.c	2011/07/21 13:23:49	1.101
@@ -62,6 +62,7 @@
 	struct config_tree cft;
 	struct dm_pool *mem;
 	time_t timestamp;
+	off_t st_size;
 	char *filename;
 	int exists;
 	int keep_open;
@@ -309,6 +310,7 @@
 	}
 
 	c->timestamp = info.st_ctime;
+	c->st_size = info.st_size;
 
 	return r;
 }
@@ -352,7 +354,7 @@
 	}
 
 	/* Unchanged? */
-	if (c->timestamp == info.st_ctime)
+	if (c->timestamp == info.st_ctime && c->st_size == info.st_size)
 		return 0;
 
       reload:


