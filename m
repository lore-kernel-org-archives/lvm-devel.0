From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:28 -0400
Subject: master - lvconvert: preserve regionsize from existing mirror
Message-ID: <201804232043.w3NKhSWl004997@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66f4f8c27f6520edc79bafe4aa829d75b3d5e854
Commit:        66f4f8c27f6520edc79bafe4aa829d75b3d5e854
Parent:        ae274617770aa44263619151ef24393cb8a16a79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 23 22:13:03 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

lvconvert: preserve regionsize from existing mirror

When adding leg to existing mirror - preserve its regionsize.
---
 tools/lvconvert.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 44fdd16..abdcf2c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -758,6 +758,13 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	if (*old_mimage_count != *new_mimage_count)
 		log_verbose("Adjusting mirror image count of %s", lv->name);
 
+	/* If region size is not given by user - use value from mirror */
+	if (lv_is_mirrored(lv) && !lp->region_size_supplied) {
+		lp->region_size = first_seg(lv)->region_size;
+		log_debug("Copying region size %s from existing mirror.",
+			  display_size(lv->vg->cmd, lp->region_size));
+	}
+
 	/*
 	 * Adjust log type
 	 *


