From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Apr 2016 11:10:38 +0000 (UTC)
Subject: master - cleanup: gcc warn about comparing int with uint
Message-ID: <20160412111038.198FD61B91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1be74cfd7f948123544872abb5e80994182e04d8
Commit:        1be74cfd7f948123544872abb5e80994182e04d8
Parent:        0f7975cb351158d3b2245b4262761a698c6c5d7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 12 11:47:21 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 12 11:47:51 2016 +0200

cleanup: gcc warn about comparing int with uint

---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 ++--
 lib/activate/dev_manager.c                         |    2 +-
 libdm/ioctl/libdm-iface.c                          |    6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 26fdfed..7b060ed 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -148,8 +148,8 @@ static void _umount(const char *device, int major, int minor)
 			continue; /* can't stat, skip this one */
 
 		if (S_ISBLK(st.st_mode) &&
-		    major(st.st_rdev) == major &&
-		    minor(st.st_rdev) == minor) {
+		    (int) major(st.st_rdev) == major &&
+		    (int) minor(st.st_rdev) == minor) {
 			log_error("Unmounting invalid snapshot %s from %s.", device, words[1]);
 			if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
 				log_error("Failed to umount snapshot %s from %s: %s.",
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3f91654..a0e05ad 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1687,7 +1687,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/*
 		 * FIXME compare info.major with lv->major if multiple major support
 		 */
-		if (info.exists && (info.minor != lv->minor)) {
+		if (info.exists && ((int) info.minor != lv->minor)) {
 			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
 				  "(%" PRIu32 ":%" PRIu32")",
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 2733b86..0c798f5 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1169,9 +1169,9 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 
 		if (!_dm_multiple_major_support && dmt->allow_default_major_fallback &&
-		    dmt->major != _dm_device_major) {
-			log_verbose("Overriding major number of %" PRIu32 
-				    " with %" PRIu32 " for persistent device.",
+		    dmt->major != (int) _dm_device_major) {
+			log_verbose("Overriding major number of %d "
+				    "with %u for persistent device.",
 				    dmt->major, _dm_device_major);
 			dmt->major = _dm_device_major;
 		}


