From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:26 +0100
Subject: [PATCH 22/29] Ensure pointer first is notnull before dereference
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <2e0d78bc8fb02ee82c80cc41aca8a3710049b7a7.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Modify code to put check into local function.

Old code expected  _check_vgs had been give  non empty pvs list which
should ensure some 'first' pointer is defined.

New code remove check for empty pvs list before call of _check_vgs
and leave this case to be handle inside this function - this
makes static analyzer less confused.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/format1.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 0dcec05..0745890 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -102,7 +102,10 @@ static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 		pv_count++;
 	}
 
-	/* On entry to fn, list known to be non-empty */
+	/* Empty pvs list is not valid */
+	if (!first)
+		return 0;
+
 	if (pv_count != first->vgd.pv_cur) {
 		log_error("%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
@@ -187,9 +190,6 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	if (!vg)
 		goto_bad;
 
-	if (dm_list_empty(pvs))
-		goto_bad;
-
 	vg->cmd = fid->fmt->cmd;
 	vg->vgmem = mem;
 	vg->fid = fid;
-- 
1.7.3.2


