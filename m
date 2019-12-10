From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:39 -0500
Subject: master - vg_read: use else for 3 case
Message-ID: <65832.119121009463300509@us-mta-393.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=abc0a8faba2a1437f4f9d158310acb8af6ab2fe5
Commit:        abc0a8faba2a1437f4f9d158310acb8af6ab2fe5
Parent:        5555765cfc71a87eadcb1f6ac9bdd41f2e3c9052
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 15:09:27 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

vg_read: use else for 3 case

Make it visible we check for ==, >, <  of same var.
---
 lib/metadata/metadata.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5856a92..24958d0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4878,10 +4878,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		if (vg->seqno == vg_ret->seqno) {
 			release_vg(vg);
-			continue;
-		}
-
-		if (vg->seqno > vg_ret->seqno) {
+		} else if (vg->seqno > vg_ret->seqno) {
 			log_warn("WARNING: ignoring metadata seqno %u on %s for seqno %u on %s for VG %s.",
 				 vg_ret->seqno, dev_name(dev_ret),
 				 vg->seqno, dev_name(mda_dev), vg->name);
@@ -4890,17 +4887,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			vg_ret = vg;
 			dev_ret = mda_dev;
 			vg_fmtdata = NULL;
-			continue;
-		}
-
-		if (vg_ret->seqno > vg->seqno) {
+		} else { /* vg->seqno < vg_ret->seqno */
 			log_warn("WARNING: ignoring metadata seqno %u on %s for seqno %u on %s for VG %s.",
 				 vg->seqno, dev_name(mda_dev),
 				 vg_ret->seqno, dev_name(dev_ret), vg->name);
 			found_old_metadata = 1;
 			release_vg(vg);
 			vg_fmtdata = NULL;
-			continue;
 		}
 	}
 



