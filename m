From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  7 Apr 2016 22:22:19 +0000 (UTC)
Subject: master - lvcreate: %FREE -> %PVS
Message-ID: <20160407222219.28AC660F86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=097a724bda160e4c0b5c7760e7a710d3e00b898c
Commit:        097a724bda160e4c0b5c7760e7a710d3e00b898c
Parent:        e2d4f53c827a14597e51956adb2202d32660f54c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 7 11:12:49 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 7 22:32:08 2016 +0200

lvcreate: %FREE -> %PVS

This is hotfix for RHBZ: https://bugzilla.redhat.com/1324537
However already the %FREE is not a good fit and we need something
better. Meanwhile make  -l%PVS work at least as good as %FREE
for thin-pool.

TODO: this needs rework - it should be allocator to do all the size
decisions at one place.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c940b6..8387eab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.150 -
 =================================
+  Reuse %FREE size aproximation with lvcreate -l%PVS thin-pool.
   Allow the lvmdump directory to exist already provided it is empty.
   Show lvconverted percentage with 2 decimal digits.
   Fix regression in suspend when repairing --type mirror (2.02.133).
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 283e52a..9714789 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -368,7 +368,7 @@ static int _update_extents_params(struct volume_group *vg,
 					&lp->discards, &lp->zero))
 			return_0;
 
-		if (lcp->percent == PERCENT_FREE) {
+		if (lcp->percent == PERCENT_FREE || lcp->percent == PERCENT_PVS) {
 			if (lp->extents <= (2 * lp->pool_metadata_extents)) {
 				log_error("Not enough space for thin pool creation.");
 				return 0;


