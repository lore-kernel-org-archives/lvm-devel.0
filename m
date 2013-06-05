From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:41 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvresize: check for max snapshot size
Message-ID: <20130605120441.D49AB6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ced1bf694359a67162cccc7f0e3d94e50929f6e
Commit:        3ced1bf694359a67162cccc7f0e3d94e50929f6e
Parent:        bd3ece0128926cc156b7fcb6409acc1a2afb16db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 21:23:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:35:23 2013 +0200

lvresize: check for max snapshot size

As for lvcreate, lvresize also doesn't need to grow bigger then needed.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d757e2b..7589f12 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Detect maximum usable size for snapshot for lvresize.
   Creation of snapshot takes at most 100% origin coverage.
   Add cow_max_extents() to calc extents for 100% origin coverage.
   For creation of snapshot require size for at least 3 chunks.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b1008ec..a32930e 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -527,6 +527,16 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return EINVALID_CMD_LINE;
 		}
 		lp->extents += lv->le_count;
+		if (lv_is_cow(lv)) {
+			extents_used = cow_max_extents(origin_from_cow(lv), find_cow(lv)->chunk_size);
+			if (extents_used < lp->extents) {
+				log_print_unless_silent("Reached maximum COW size %s.",
+							display_size(vg->cmd, (uint64_t) vg->extent_size * extents_used));
+				lp->extents = extents_used;
+				if (lp->extents == lv->le_count)
+					return ECMD_PROCESSED;
+			}
+		}
 	}
 
 	if (lp->sign == SIGN_MINUS) {


