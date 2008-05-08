From: agk@sourceware.org <agk@sourceware.org>
Date: 8 May 2008 18:28:27 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20080508182827.636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-08 18:28:27

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	When asked to drop cached committed VG metadata, invalidate cached PV labels.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.868&r2=1.869
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2008/05/08 18:06:58	1.868
+++ LVM2/WHATS_NEW	2008/05/08 18:28:27	1.869
@@ -5,6 +5,7 @@
 
 Version 2.02.37 - 
 =================================
+  When asked to drop cached committed VG metadata, invalidate cached PV labels.
   Drop metadata cache before writing precommitted metadata instead of after.
   Don't touch /dev in vgrename if activation is disabled.
 
--- LVM2/lib/cache/lvmcache.c	2008/04/24 02:22:06	1.47
+++ LVM2/lib/cache/lvmcache.c	2008/05/08 18:28:27	1.48
@@ -22,6 +22,9 @@
 #include "filter.h"
 #include "memlock.h"
 #include "str_list.h"
+#include "format-text.h"
+#include "format_pool.h"
+#include "format1.h"
 
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
@@ -130,16 +133,39 @@
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-void lvmcache_drop_metadata(const char *vgname)
+static void _drop_metadata(const char *vgname)
 {
 	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
 
 	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
 		return;
 
+	/*
+	 * Invalidate cached PV labels.
+	 * If cached precommitted metadata exists that means we
+	 * already invalidated the PV labels (before caching it)
+	 * and we must not do it again.
+	 */
+
+	if (!vginfo->precommitted)
+		list_iterate_items(info, &vginfo->infos)
+			info->status |= CACHE_INVALID;
+
 	_free_cached_vgmetadata(vginfo);
 }
 
+void lvmcache_drop_metadata(const char *vgname)
+{
+	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */
+	if (strcmp(vgname, VG_ORPHANS)) {
+		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME);
+		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME);
+		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME);
+	} else
+		_drop_metadata(vgname);
+}
+
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {


