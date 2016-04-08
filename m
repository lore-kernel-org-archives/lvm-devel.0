From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 Apr 2016 18:22:13 +0000 (UTC)
Subject: master - dev_manager: device_is_usable does not flush
Message-ID: <20160408182213.78DA760DCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a09d65891fcf97130dd595eba320b647638d9a07
Commit:        a09d65891fcf97130dd595eba320b647638d9a07
Parent:        f40dfb48ad0114c89ac5fc0a8670a3792565e9a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 8 16:00:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 8 20:20:04 2016 +0200

dev_manager: device_is_usable does not flush

When scanning if device is being usable as PV,
we call STATUS - but this status should not cause
any flushing.
Skip also open_count information as it's not needed.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 21970a8..0fa9f50 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.150 -
 =================================
+  Avoid using flushing dm status ioctl when checking for usable DM device.
   Check for devices without LVM- uuid prefix only with kernels < 3.X.
   Reuse %FREE size aproximation with lvcreate -l%PVS thin-pool.
   Allow the lvmdump directory to exist already provided it is empty.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 89fa9e9..f2e3826 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -553,7 +553,14 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 
 	if (activation_checks() && !dm_task_enable_checks(dmt))
 		goto_out;
-		
+
+	/* Non-blocking status read */
+	if (!dm_task_no_flush(dmt))
+		log_warn("WARNING: Can't set no_flush for dm status.");
+
+	if (!dm_task_no_open_count(dmt))
+		goto_out;
+
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device");
 		goto out;


