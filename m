From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Aug 2013 12:22:07 +0000 (UTC)
Subject: master - filter-mpath: remove superfluous error message about mpath major not equal to dm major
Message-ID: <20130821122207.2FFAD60E76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8daa15270e0e1085776bd227331863e7cf408ae
Commit:        c8daa15270e0e1085776bd227331863e7cf408ae
Parent:        f0be9ac9047a30bb2befe6a8d9130f466d37d9fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 21 14:07:01 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 21 14:07:01 2013 +0200

filter-mpath: remove superfluous error message about mpath major not equal to dm major

This is a regression caused by commit 3bd90488545a4ad5374b4e0f1daba6cf16ae6ae8.
The error message added with that commit "mpath major %d is not dm major %d" is
superfluous.

When scanning for mpath components, we're looking for a parent device.
But this parent device is not necessarily an mpath device (so the dm device)
if it exists - it can be any other device layered on top (e.g. an MD RAID device).
---
 WHATS_NEW                  |    1 +
 lib/filters/filter-mpath.c |    5 +----
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0d58e66..6c0514f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Remove "mpath major is not dm major" msg for mpath component scan (2.02.94).
   Prevent cluster mirror logs from being corrupted by redundant checkpoints.
   Fix ignored lvmetad update on loop device configuration (2.02.99).
   Use LVM_PATH instead of hardcoded value in lvm2 activation systemd generator.
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 1db2264..a9881fd 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -181,11 +181,8 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 	if (!get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
 		return_0;
 
-	if (major != dt->device_mapper_major) {
-		log_error("mpath major %d is not dm major %d.", major,
-			  dt->device_mapper_major);
+	if (major != dt->device_mapper_major)
 		return 0;
-	}
 
 	return lvm_dm_prefix_check(major, minor, MPATH_PREFIX);
 }


