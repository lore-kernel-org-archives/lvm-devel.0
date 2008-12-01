From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Dec 2008 17:38:36 -0000
Subject: LVM2 lib/display/display.c ./WHATS_NEW
Message-ID: <20081201173836.1555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-12-01 17:38:35

Modified files:
	lib/display    : display.c 
	.              : WHATS_NEW 

Log message:
	Fix uninitialised lv_count in vgdisplay -c

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1001&r2=1.1002

--- LVM2/lib/display/display.c	2008/11/03 22:14:28	1.94
+++ LVM2/lib/display/display.c	2008/12/01 17:38:35	1.95
@@ -656,7 +656,7 @@
 void vgdisplay_colons(const struct volume_group *vg)
 {
 	uint32_t active_pvs;
-	uint32_t lv_count;
+	uint32_t lv_count = 0;
 	struct lv_list *lvl;
 	const char *access_str;
 	char uuid[64] __attribute((aligned(8)));
--- LVM2/WHATS_NEW	2008/11/27 18:13:50	1.1001
+++ LVM2/WHATS_NEW	2008/12/01 17:38:35	1.1002
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix uninitialised lv_count in vgdisplay -c.
   Don't skip updating pvid hash when lvmcache_info struct got swapped.
   Add tinfo to termcap search path for pld-linux.
   Fix startup race in clvmd.


