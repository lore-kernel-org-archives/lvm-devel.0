From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:06 -0400
Subject: master - activation: synchronize before removing devices
Message-ID: <201903201340.x2KDe6PF012560@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4411fe2ba855b9c42b5d1393fc08faf01b1d2636
Commit:        4411fe2ba855b9c42b5d1393fc08faf01b1d2636
Parent:        677aa84be3b41e94514aa5c1560e987e7763b294
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 6 12:37:47 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:39:09 2019 +0100

activation: synchronize before removing devices

Udev is running udev-rule action upon 'resume'.

However lvm2 in special case is doing replacement of
'soon-to-be-removed' device with 'error' target for resuming
and then follows actual removal - the sequence is usually quick,
so when udev start action - it can result in 'strange' error
message in kernel log like:

Process '/usr/sbin/dmsetup info -j 253 -m 17 -c --nameprefixes --noheadings --rows -o name,uuid,suspended' failed with exit code 1.

To avoid this - we need to ensure there is synchronization wait for udev
between 'resume'  and 'remove' part of this process.

However existing code put strict requirement to avoid synchronizing with
udev inside critical section - but this originally came from requirement
to not do anything special while there could be devices in
suspend-state. Now we are able to see differnce between critical section
with or without suspended devices.  For udev synchronization only
suspended devices are prohibited to be there - so slightly relax
condition and allow calling and using 'fs_sync()' even inside critical
section - but there must not be any suspended device.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   13 +++++++++++++
 lib/activate/fs.c          |    3 ++-
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 18733b1..0f1fe1b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Add synchronization with udev before removing cached devices.
   Add support for caching VDO LVs and VDOPOOL LVs.
   Add support for vgsplit with cached devices.
   Query mpath device only once per command for its state.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 09fca63..981f467 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3716,6 +3716,19 @@ int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv
 	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
+	/*
+	 * When lvm2 resumes a device and shortly after that it removes it,
+	 * udevd rule will try to blindly call 'dmsetup info' on already removed
+	 * device leaving the trace inside syslog about failing operation.
+	 *
+	 * TODO: It's not completely clear this call here is the best fix.
+	 *       Maybe there can be a better sequence, but ATM we do usually resume
+	 *       error device i.e. on cache deletion and remove it.
+	 * TODO2: there could be more similar cases!
+	 */
+	if (!dm_list_empty(&dm->pending_delete))
+		fs_unlock();
+
 	if (!_tree_action(dm, lv, laopts, CLEAN))
 		return_0;
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 87bc724..b2c99fc 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -487,7 +487,8 @@ int fs_rename_lv(const struct logical_volume *lv, const char *dev,
 
 void fs_unlock(void)
 {
-	if (!prioritized_section()) {
+	/* Do not allow syncing device name with suspended devices */
+	if (!dm_get_suspended_counter()) {
 		log_debug_activation("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))


