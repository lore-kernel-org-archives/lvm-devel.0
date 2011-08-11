From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 14:00:59 -0000
Subject: LVM2/lib/raid raid.c
Message-ID: <20110811140059.30957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 14:00:58

Modified files:
	lib/raid       : raid.c 

Log message:
	Need 'ifdef' checks around RAID monitoring functions as well to catch the
	case where the user does not want dmeventd support compiled in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/raid/raid.c	2011/08/11 13:30:36	1.3
+++ LVM2/lib/raid/raid.c	2011/08/11 14:00:58	1.4
@@ -262,6 +262,8 @@
 	dm_free((void *) segtype);
 }
 
+#ifdef DEVMAPPER_SUPPORT
+#ifdef DMEVENTD
 static const char *_get_raid_dso_path(struct cmd_context *cmd)
 {
 	const char *config_str = find_config_tree_str(cmd, "dmeventd/raid_library",
@@ -294,7 +296,8 @@
 {
 	return _raid_set_events(seg, events, 0);
 }
-
+#endif /* DEVMAPPER_SUPPORT */
+#endif /* DMEVENTD */
 static struct segtype_handler _raid_ops = {
 	.name = _raid_name,
 	.text_import_area_count = _raid_text_import_area_count,


