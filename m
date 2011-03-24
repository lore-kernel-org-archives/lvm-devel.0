From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 12:16:35 +0100
Subject: [PATCH 2/4] Fix access to released memory
In-Reply-To: <cover.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
Message-ID: <4243866e4a2da7915b2beecef105358c658664e4.1300965223.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Somewhat tricky part of the code.

Invalid primary_vginfo  was supposed to move all its lvmcache_info to
orphan_vginfo - however it has called _drop_vginfo() inside the loop
that remove primary_vginfo itself - thus made the loop using released
memory.

Patch used _vginfo_detach_info() instead and call _drop_vginfo after
this whole loop is finished.

Here is valgrind trace it should be fixed:

Invalid read of size 8
   at 0x41E960: _lvmcache_update_vgname (lvmcache.c:1229)
   by 0x41EF86: lvmcache_update_vgname_and_id (lvmcache.c:1360)
   by 0x441393: _text_read (text_label.c:329)
   by 0x442221: label_read (label.c:289)
   by 0x41CF92: lvmcache_label_scan (lvmcache.c:635)
   by 0x45B303: _vg_read_by_vgid (metadata.c:3342)
   by 0x45B4A6: lv_from_lvid (metadata.c:3381)
   by 0x41B555: lv_activation_filter (activate.c:1346)
   by 0x415868: do_activate_lv (lvm-functions.c:343)
   by 0x415E8C: do_lock_lv (lvm-functions.c:532)
   by 0x40FD5F: do_command (clvmd-command.c:120)
   by 0x413D7B: process_local_command (clvmd.c:1686)
 Address 0x63eba10 is 16 bytes inside a block of size 160 free'd
   at 0x4C2756E: free (vg_replace_malloc.c:366)
   by 0x41DE70: _free_vginfo (lvmcache.c:980)
   by 0x41DEDA: _drop_vginfo (lvmcache.c:998)
   by 0x41E854: _lvmcache_update_vgname (lvmcache.c:1238)
   by 0x41EF86: lvmcache_update_vgname_and_id (lvmcache.c:1360)
   by 0x441393: _text_read (text_label.c:329)
   by 0x442221: label_read (label.c:289)
   by 0x41CF92: lvmcache_label_scan (lvmcache.c:635)
   by 0x45B303: _vg_read_by_vgid (metadata.c:3342)
   by 0x45B4A6: lv_from_lvid (metadata.c:3381)
   by 0x41B555: lv_activation_filter (activate.c:1346)
   by 0x415868: do_activate_lv (lvm-functions.c:343)

problematic line:
dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4e2e158..ee7d278 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1107,17 +1107,17 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		 * Otherwise we risk bogus warnings of duplicate VGs.
 		 */
 		while ((primary_vginfo = vginfo_from_vgname(vgname, NULL)) &&
-		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
+		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo)) {
+			orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+			if (!orphan_vginfo) {
+				log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
+					  primary_vginfo->fmt->orphan_vg_name);
+				dm_free(vginfo->vgname);
+				dm_free(vginfo);
+				return 0;
+			}
 			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
-				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
-				if (!orphan_vginfo) {
-					log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
-						  primary_vginfo->fmt->orphan_vg_name);
-					dm_free(vginfo->vgname);
-					dm_free(vginfo);
-					return 0;
-				}
-				_drop_vginfo(info2, primary_vginfo);	
+				_vginfo_detach_info(info2);
 				_vginfo_attach_info(orphan_vginfo, info2);
 				if (info2->mdas.n)
 					sprintf(mdabuf, " with %u mdas",
@@ -1129,6 +1129,10 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 					  vgname, orphan_vginfo->vgid[0] ? " (" : "",
 					  orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
 					  orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
+			}
+
+			if (!_drop_vginfo(NULL, primary_vginfo))
+				return_0;
 		}
 
 		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host,
-- 
1.7.4.1


