From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:10 -0500
Subject: master - cov: remove uneeded code
Message-ID: <201811051627.wA5GRAnf005347@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6235861e64e9567493e14c6f227a6cc5ce609e07
Commit:        6235861e64e9567493e14c6f227a6cc5ce609e07
Parent:        1951e0db0f0cdeddc9d84fbea0fc174ed61e8b9a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:29:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:09:36 2018 +0100

cov: remove uneeded code

Since clvmd was dropped this code become useless.
---
 lib/activate/activate.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 93448d3..1e195b6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2031,8 +2031,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	               const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	const struct logical_volume *pvmove_lv = NULL;
-	const struct logical_volume *lv_to_free = NULL;
-	const struct logical_volume *lv_pre_to_free = NULL;
 	struct logical_volume *lv_pre_tmp, *lv_tmp;
 	struct seg_list *sl;
 	struct lv_segment *snap_seg;
@@ -2223,10 +2221,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 out:
 	if (mem)
 		dm_pool_destroy(mem);
-	if (lv_pre_to_free)
-		release_vg(lv_pre_to_free->vg);
-	if (lv_to_free)
-		release_vg(lv_to_free->vg);
 
 	return r;
 }
@@ -2387,7 +2381,6 @@ static int _lv_has_open_snapshots(const struct logical_volume *lv)
 
 int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logical_volume *lv)
 {
-	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	static const struct lv_activate_opts laopts = { .skip_in_use = 1 };
 	struct dm_list *snh;
@@ -2457,8 +2450,6 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 		r = 0;
 	}
 out:
-	if (lv_to_free)
-		release_vg(lv_to_free->vg);
 
 	return r;
 }


