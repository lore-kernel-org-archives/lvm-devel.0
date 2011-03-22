From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:16 +0100
Subject: [PATCH 7/8] Proposal - avoid parsing same data
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <439f1f6518015f8775fec13ca96188bee73474cd.1300829384.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of regenerating config tree and parsing same data again,
check whether export_vg_to_buffer does not produce same string as
the one already cached - in this case keep it, otherwise throw cached
content away.

For the code simplicity calling _free_cached_vgmetadata() with
vgmetadata == NULL as the function handles this itself.

Note: sometimes export_vg_to_buffer() generates almost the same data
with just different time stamp, but for the patch simplicity,
data are reparsed in this case.

This patch currently helps for vgrefresh.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |   17 +++++++++++++----
 lib/cache/lvmcache.h |    1 +
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4e2e158..037fc4a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -99,6 +99,7 @@ static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
+	char *data;
 	int size;
 
 	if (!(vginfo = vginfo_from_vgid((const char *)&vg->id))) {
@@ -106,14 +107,22 @@ static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 		return;
 	}
 
-	if (vginfo->vgmetadata)
-		_free_cached_vgmetadata(vginfo);
-
-	if (!(size = export_vg_to_buffer(vg, &vginfo->vgmetadata))) {
+	if (!(size = export_vg_to_buffer(vg, &data))) {
 		stack;
+		_free_cached_vgmetadata(vginfo);
 		return;
 	}
 
+	/* Avoid reparsing of the same data string */
+	if (vginfo->vgmetadata && vginfo->vgmetadata_size == size &&
+	    strcmp(vginfo->vgmetadata, data) == 0)
+		dm_free(data);
+	else {
+		_free_cached_vgmetadata(vginfo);
+		vginfo->vgmetadata_size = size;
+		vginfo->vgmetadata = data;
+	}
+
 	vginfo->precommitted = precommitted;
 
 	if (!id_write_format((const struct id *)vginfo->vgid, uuid, sizeof(uuid))) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 080f3b5..f13cad2 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -46,6 +46,7 @@ struct lvmcache_vginfo {
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	size_t vgmetadata_size;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
-- 
1.7.4.1


