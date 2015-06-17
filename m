From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jun 2015 12:28:01 +0000 (UTC)
Subject: master - cleanup: missing target_type check in device_is_usable filter
Message-ID: <20150617122801.296F561028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a203070f5189a53f764e1e6e960ac70acfad5a9
Commit:        0a203070f5189a53f764e1e6e960ac70acfad5a9
Parent:        5577f2f4f0a5518662b9cedb6a373ccb67a71917
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 17 14:27:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 17 14:27:48 2015 +0200

cleanup: missing target_type check in device_is_usable filter

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 43e006a..f4b2a4a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -638,7 +638,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		 * correctly, not just snapshots but any cobimnation possible
 		 * in a stack - use proper dm tree to check this instead.
 		 */
-		if (check.check_suspended &&
+		if (check.check_suspended && target_type &&
 		    (!strcmp(target_type, "snapshot") || !strcmp(target_type, "snapshot-origin")) &&
 		    _ignore_suspended_snapshot_component(dev)) {
 			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);


