From: David Teigland <teigland@sourceware.org>
Date: Thu, 29 Nov 2018 13:35:39 -0500
Subject: 2018-06-01-stable - scan: md metadata version 0.90 is at the end of disk
Message-ID: <201811291835.wATIZdhh015315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e42ebd6d4012d210084a9ccf8d76f853726de3c
Commit:        0e42ebd6d4012d210084a9ccf8d76f853726de3c
Parent:        fe1cabfa3469b5a5ac673385785b031d6a702bb4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 29 11:51:05 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 29 12:16:37 2018 -0600

scan: md metadata version 0.90 is at the end of disk

commit de28637
  scan: use full md filter when md 1.0 devices are present

missed the fact that md superblock version 0.90 also puts
metadata at the end of the device, so the full md filter
needs to be used when either 0.90 or 1.0 is present.
---
 lib/device/dev-md.c     |    2 +-
 lib/filters/filter-md.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 7196dc0..185499b 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -422,7 +422,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev)
 	log_very_verbose("Device %s %s is %s.",
 			 dev_name(dev), attribute, version_string);
 
-	if (!strcmp(version_string, "1.0"))
+	if (!strcmp(version_string, "1.0") || !strcmp(version_string, "0.90"))
 		return 1;
 	return 0;
 }
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index e03ff50..2011e1d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -47,7 +47,7 @@ extern int use_full_md_check;
  * 3. use udev to detect components
  *
  * mode 1 will not detect and exclude components of md devices
- * that use superblock version 1.0 which is at the end of the device.
+ * that use superblock version 0.9 or 1.0 which is at the end of the device.
  *
  * mode 2 will detect these, but mode 2 doubles the i/o done by label
  * scan, since there's a read at both the start and end of every device.
@@ -60,11 +60,11 @@ extern int use_full_md_check;
  *
  * - the command is pvcreate/vgcreate/vgextend, which format new
  *   devices, and if the user ran these commands on a component
- *   device of an md device 1.0, then it would cause problems.
+ *   device of an md device 0.9 or 1.0, then it would cause problems.
  *   FIXME: this would only really need to scan the end of the
  *   devices being formatted, not all devices.
  *
- * - it sees an md device on the system using version 1.0.
+ * - it sees an md device on the system using version 0.9 or 1.0.
  *   The point of this is just to avoid displaying md components
  *   from the 'pvs' command.
  *   FIXME: the cost (double i/o) may not be worth the benefit


