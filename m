From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Aug 2021 20:06:06 +0000 (GMT)
Subject: main - vdo: skip zeroing for VDO LV
Message-ID: <20210831200606.E488E3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88360b0c512d96dfe05c11362ff389ef6bfec6b4
Commit:        88360b0c512d96dfe05c11362ff389ef6bfec6b4
Parent:        62c599f78151e65105c92c87ac406e3f3f360b1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 26 23:04:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 31 22:05:47 2021 +0200

vdo: skip zeroing for VDO LV

Since VDO is always returns 'zero' on unprovisioned read
and every provisioned block is always 'zeroed' on partial writes,
we can avoid 'zeroing' of such LVs.
---
 lib/metadata/lv_manip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a26d3d533..730e3f0df 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8073,6 +8073,10 @@ static int _should_wipe_lv(struct lvcreate_params *lp,
 	     first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))
 		return 0;
 
+	/* VDO LV do not need to be zeroed */
+	if (lv_is_vdo(lv))
+		return 0;
+
 	if (warn && (lv_passes_readonly_filter(lv))) {
 		log_warn("WARNING: Read-only activated logical volume %s not zeroed.",
 			 display_lvname(lv));


