From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:05:13 -0000
Subject: LVM2/tools polldaemon.c
Message-ID: <20090701170513.3795.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:05:12

Modified files:
	tools          : polldaemon.c 

Log message:
	Add lvmcache_init() to polldaemon initialization.
	
	Signed-off-by: Petr Rockai <me@mornfall.net>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/tools/polldaemon.c	2009/07/01 17:00:52	1.19
+++ LVM2/tools/polldaemon.c	2009/07/01 17:05:12	1.20
@@ -57,6 +57,7 @@
 	strncpy(*cmd->argv, "(lvm2copyd)", strlen(*cmd->argv));
 
 	reset_locking();
+	lvmcache_init();
 	dev_close_all();
 
 	return 1;


