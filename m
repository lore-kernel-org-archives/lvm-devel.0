From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Sep 2015 09:11:40 +0000 (UTC)
Subject: master - wiping: warn if use_blkid_wiping=1 is set and LVM not compiled with blkid_wiping support
Message-ID: <20150922091140.82D7360F51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2081071bee76bcd168cccbf039a2fac663048c10
Commit:        2081071bee76bcd168cccbf039a2fac663048c10
Parent:        47f623d64b6432fbb3533cb72132c947eeb01941
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 22 11:11:26 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 22 11:11:26 2015 +0200

wiping: warn if use_blkid_wiping=1 is set and LVM not compiled with blkid_wiping support

---
 lib/device/dev-type.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index db40792..25f11d1 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -734,13 +734,20 @@ int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
 			  uint32_t types_no_prompt, int yes, force_t force,
 			  int *wiped)
 {
+	int blkid_wiping_enabled = find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL);
+
 #ifdef BLKID_WIPING_SUPPORT
-	if (find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL))
+	if (blkid_wiping_enabled)
 		return _wipe_known_signatures_with_blkid(dev, name,
 							 types_to_exclude,
 							 types_no_prompt,
 							 yes, force, wiped);
 #endif
+	if (blkid_wiping_enabled) {
+		log_warn("allocation/use_blkid_wiping=1 configuration setting is set "
+			 "while LVM is not compiled with blkid wiping support.");
+		log_warn("Falling back to native LVM signature detection.");
+	}
 	return _wipe_known_signatures_with_lvm(dev, name,
 					       types_to_exclude,
 					       types_no_prompt,


