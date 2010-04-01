From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  1 Apr 2010 17:57:30 -0400
Subject: [PATCH 4/6] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <1270159052-1181-4-git-send-email-dwysocha@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1270159052-1181-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2app needs a link back to the vg in order to use the vg handle for
memory allocations as well as other things.  This patch adds the field
to struct physical_volume, and sets the field when returning from
vg_read() internal library call.

NOTE: Unfortunately in the case of pv_read() callers, we cannot set
this pv->vg field properly, since the vg it belongs to may not be
known by just reading a single device, and no VG is in existence at
the time of pv_read().  Significant refactorings related to
lvmcache, PVs with 0 mdas, etc, are required to set this field
for callers of pv_read().  For now we assume that if the field is
not set, the pv is not associated with a complete VG (as returned
by vg_read()).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b02a22c..d73dc06 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -183,7 +183,7 @@ struct physical_volume {
 	const struct format_type *fmt;
 	const char *vg_name;
 	struct id vgid;
-
+	struct volume_group *vg; /* FIXME: Only valid when used with lvm2app. */
 	uint64_t status;
 	uint64_t size;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a60ea34..6063744 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -143,6 +143,7 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 	vg->pv_count++;
 	vg->extent_count += pvl->pv->pe_count;
 	vg->free_count += pvl->pv->pe_count;
+	pvl->pv->vg = vg;
 }
 
 
-- 
1.6.0.6


