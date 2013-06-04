From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:35 +0000 (UTC)
Subject: dev-mornfall-activate - lvcreate: reduce too large cow
Message-ID: <20130604192735.E03B961095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd3ece0128926cc156b7fcb6409acc1a2afb16db
Commit:        bd3ece0128926cc156b7fcb6409acc1a2afb16db
Parent:        eb7e206a73a4fae5b93ffcdf96640675f7a72a73
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 21:43:46 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:35:14 2013 +0200

lvcreate: reduce too large cow

Detect maximum usable size of snapshot COW device,
and do not waste more space for such LV then needed.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7eb82a..d757e2b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Creation of snapshot takes at most 100% origin coverage.
   Add cow_max_extents() to calc extents for 100% origin coverage.
   For creation of snapshot require size for at least 3 chunks.
   Fix lvresize --use-policies of VALID but 100% full snapshot.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7580155..497c474 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -241,6 +241,7 @@ static int _update_extents_params(struct volume_group *vg,
 	struct logical_volume *origin = NULL;
 	uint32_t size_rest;
 	uint32_t stripesize_extents;
+	uint32_t extents;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -299,6 +300,23 @@ static int _update_extents_params(struct volume_group *vg,
 			break;
 	}
 
+	if (lp->snapshot && lp->origin) {
+		if (!origin && !(origin = find_lv(vg, lp->origin))) {
+			log_error("Couldn't find origin volume '%s'.",
+				  lp->origin);
+			return 0;
+		}
+
+		extents = cow_max_extents(origin, lp->chunk_size);
+
+		if (extents < lp->extents) {
+				log_print_unless_silent("Reducing COW size %s down to maximum usable size %s.",
+						display_size(vg->cmd, (uint64_t) vg->extent_size * lp->extents),
+						display_size(vg->cmd, (uint64_t) vg->extent_size * extents));
+			lp->extents = extents;
+		}
+	}
+
 	if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
 		stripesize_extents = 1;
 


