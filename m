From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:22 +0100
Subject: [PATCH 18/29] Check result of vginfo_from_vgname
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <5fc3db8c4744cb62207355b79f41372512484558.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Keep static code analyzers happier. In this case there is a very small
chance bug could appear (memory fault?). But as we check result from
vginfo_from_vgname in other cases - do it here as well.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 60edcec..6fb0900 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1083,6 +1083,12 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
 			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
 				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+				if (!orphan_vginfo) {
+					log_error(INTERNAL_ERROR "vginfo for orphan_vg_name failed.");
+					dm_free(vginfo->vgname);
+					dm_free(vginfo);
+					return 0;
+				}
 				_drop_vginfo(info2, primary_vginfo);	
 				_vginfo_attach_info(orphan_vginfo, info2);
 				if (info2->mdas.n)
-- 
1.7.3.2


