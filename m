From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 12:54:26 -0500
Subject: master - metadata: Consistently skip metadata areas that failed.
Message-ID: <201712121754.vBCHsQdg026102@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b96862ee11e0291cc1101ff4e17e54f9fe8da666
Commit:        b96862ee11e0291cc1101ff4e17e54f9fe8da666
Parent:        15ccea71116f4c0a587aaa0ed25dc1d8d98c0c7f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 17:49:35 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 17:52:45 2017 +0000

metadata: Consistently skip metadata areas that failed.

Even after writing some metadata encountered problems, some commands
continue (rightly or wrongly) and attempt to make further changes.

Once an mda is marked MDA_FAILED, don't try to use it again.
This also applies when reverting, where one loop already skips
failed mdas but the other doesn't.

This fixes some device open_count warnings on relevant failure paths.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9ff8b51..f6ead67 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  When writing metadata, consistently skip mdas marked as failed.
   Refactor and adjust text format metadata alignment calculation.
   Fix python3 path in lvmdbusd to use value detected by configure.
   Reduce checks for active LVs in vgchange before background polling.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 56b5b13..6c55d89 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3039,6 +3039,8 @@ int vg_write(struct volume_group *vg)
 
 	/* Write to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (mda->status & MDA_FAILED)
+			continue;
 		if (!mda->ops->vg_write) {
 			log_error("Format does not support writing volume"
 				  "group metadata areas");
@@ -3063,6 +3065,9 @@ int vg_write(struct volume_group *vg)
 		dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
 			mda = dm_list_item(mdah, struct metadata_area);
 
+			if (mda->status & MDA_FAILED)
+				continue;
+
 			if (mda->ops->vg_revert &&
 			    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 				stack;


