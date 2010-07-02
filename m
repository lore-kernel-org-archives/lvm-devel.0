From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Jul 2010 21:16:52 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/display/di ...
Message-ID: <20100702211652.15123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-02 21:16:51

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/display    : display.h 
	lib/metadata   : mirror.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add printf format attributes to yes_no_prompt & dm_{sn,as}printf and fix a calle

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1650&r2=1.1651
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.386&r2=1.387
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/WHATS_NEW	2010/07/02 17:44:17	1.1650
+++ LVM2/WHATS_NEW	2010/07/02 21:16:50	1.1651
@@ -1,5 +1,6 @@
 Version 2.02.70 - 
 ================================
+  Add printf format attributes to yes_no_prompt and fix a caller.
   Always pass unsuspended dm devices through persistent filter to other filters.
   Move test for suspended dm devices ahead of other filters.
   Fix another segfault in clvmd -R if no response from daemon received. (2.02.68)
--- LVM2/WHATS_NEW_DM	2010/07/01 10:57:03	1.386
+++ LVM2/WHATS_NEW_DM	2010/07/02 21:16:50	1.387
@@ -1,5 +1,6 @@
 Version 1.02.52 -
 ================================
+  Add printf format attributes to dm_{sn,as}printf and fix a caller.
   Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)
 
 Version 1.02.51 - 30th June 2010
--- LVM2/lib/display/display.h	2007/08/20 20:55:25	1.21
+++ LVM2/lib/display/display.h	2010/07/02 21:16:50	1.22
@@ -59,6 +59,6 @@
 const char *get_alloc_string(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
-char yes_no_prompt(const char *prompt, ...);
+char yes_no_prompt(const char *prompt, ...) __attribute__ ((format(printf, 1, 2)));
 
 #endif
--- LVM2/lib/metadata/mirror.c	2010/06/28 14:19:45	1.121
+++ LVM2/lib/metadata/mirror.c	2010/07/02 21:16:50	1.122
@@ -1543,7 +1543,7 @@
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
-				 "Proceed? [y/n]: ") == 'y')
+				 "Proceed? [y/n]: ", lv->name) == 'y')
 		sync_percent = 0;
 	else
 		return 0;
--- LVM2/libdm/libdevmapper.h	2010/06/23 17:03:15	1.117
+++ LVM2/libdm/libdevmapper.h	2010/07/02 21:16:51	1.118
@@ -66,6 +66,7 @@
 typedef void (*dm_log_fn) (int level, const char *file, int line,
 			   const char *f, ...)
     __attribute__ ((format(printf, 4, 5)));
+
 void dm_log_init(dm_log_fn fn);
 /*
  * For backward-compatibility, indicate that dm_log_init() was used
@@ -943,7 +944,8 @@
 /* 
  * Returns -1 if buffer too small
  */
-int dm_snprintf(char *buf, size_t bufsize, const char *format, ...);
+int dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
+    __attribute__ ((format(printf, 3, 4)));
 
 /*
  * Returns pointer to the last component of the path.
@@ -975,7 +977,8 @@
  * Pointer to the buffer is stored in *buf.
  * Returns -1 on failure leaving buf undefined.
  */
-int dm_asprintf(char **buf, const char *format, ...);
+int dm_asprintf(char **buf, const char *format, ...)
+    __attribute__ ((format(printf, 2, 3)));
 
 /*********************
  * regular expressions
--- LVM2/libdm/libdm-deptree.c	2010/06/21 08:54:32	1.83
+++ LVM2/libdm/libdm-deptree.c	2010/07/02 21:16:51	1.84
@@ -1442,7 +1442,7 @@
 	struct seg_area *area;
 	char devbuf[DM_FORMAT_DEV_BUFSIZE];
 	unsigned first_time = 1;
-	const char *logtype;
+	const char *logtype, *synctype;
 	unsigned log_parm_count;
 
 	dm_list_iterate_items(area, &seg->areas) {
@@ -1475,12 +1475,12 @@
 				EMIT_PARAMS(*pos, " %s %u%s %" PRIu64, logtype,
 					    log_parm_count, devbuf, area->region_size);
 
-				logtype = (area->flags & DM_NOSYNC) ?
-					" nosync" : (area->flags & DM_FORCESYNC) ?
-					" sync" : NULL;
+				synctype = (area->flags & DM_NOSYNC) ?
+						" nosync" : (area->flags & DM_FORCESYNC) ?
+								" sync" : NULL;
 
-				if (logtype)
-					EMIT_PARAMS(*pos, logtype);
+				if (synctype)
+					EMIT_PARAMS(*pos, "%s", synctype);
 			}
 			break;
 		default:


