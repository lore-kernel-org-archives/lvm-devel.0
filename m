From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Apr 2011 14:37:07 +0200
Subject: [PATCH 1/1] Fix use of vgname and vgid
In-Reply-To: <cover.1303302985.git.zkabelac@redhat.com>
References: <cover.1303302985.git.zkabelac@redhat.com>
Message-ID: <846e0fef3eefcc011e9ff4b70d9a8be007d475b1.1303302985.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid using of free memory when duplicated MDA is found.

As get_pv_from_vg_by_id() may call lvmcache_label_scan() keep the vgname
and vgid copied localy on the stack as vginfo may dissapear and code was
then accessing garbage in memory.

i.e.  pvs  /dev/loop0
(when /dev/loop0 and /dev/loop1 has same MDA content)

Invalid read of size 1
   at 0x523C986: dm_hash_lookup (hash.c:325)
   by 0x440C8C: vginfo_from_vgname (lvmcache.c:399)
   by 0x4605C0: _create_vg_text_instance (format-text.c:1882)
   by 0x46140D: _text_create_text_instance (format-text.c:2243)
   by 0x47EB49: _vg_read (metadata.c:2887)
   by 0x47FBD8: vg_read_internal (metadata.c:3231)
   by 0x477594: get_pv_from_vg_by_id (metadata.c:344)
   by 0x45F07A: _get_pv_if_in_vg (format-text.c:1400)
   by 0x45F0B9: _populate_pv_fields (format-text.c:1414)
   by 0x45F40F: _text_pv_read (format-text.c:1493)
   by 0x480431: _pv_read (metadata.c:3500)
   by 0x4802B2: pv_read (metadata.c:3462)
 Address 0x652ab80 is 0 bytes inside a block of size 4 free'd
   at 0x4C2756E: free (vg_replace_malloc.c:366)
   by 0x442277: _free_vginfo (lvmcache.c:963)
   by 0x44235E: _drop_vginfo (lvmcache.c:992)
   by 0x442B23: _lvmcache_update_vgname (lvmcache.c:1165)
   by 0x443449: lvmcache_update_vgname_and_id (lvmcache.c:1358)
   by 0x443C07: lvmcache_add (lvmcache.c:1492)
   by 0x46588C: _text_read (text_label.c:271)
   by 0x466A65: label_read (label.c:289)
   by 0x4413FC: lvmcache_label_scan (lvmcache.c:635)
   by 0x4605AD: _create_vg_text_instance (format-text.c:1881)
   by 0x46140D: _text_create_text_instance (format-text.c:2243)
   by 0x47EB49: _vg_read (metadata.c:2887)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/format-text.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b8b4fc1..8d3b531 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1396,10 +1396,23 @@ static int _get_pv_if_in_vg(struct lvmcache_info *info,
 			    struct physical_volume *pv)
 {
 	if (info->vginfo && info->vginfo->vgname &&
-	    !is_orphan_vg(info->vginfo->vgname) &&
-	    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
-				 info->vginfo->vgid, info->dev->pvid, pv))
-		return 1;
+	    !is_orphan_vg(info->vginfo->vgname)) {
+		char vgname[NAME_LEN + 1];
+		char vgid[ID_LEN + 1];
+
+		/*
+		 * get_pv_from_vg_by_id() may lead to
+		 * lvmcache_label_scan() so it can drop
+		 * vginfo and all referenced data.
+		 */
+		strcpy(vgname, info->vginfo->vgname);
+		vgname[PATH_MAX] = '\0';
+		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
+
+		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
+					 info->dev->pvid, pv))
+			return 1;
+	}
 
 	return 0;
 }
-- 
1.7.4.4


