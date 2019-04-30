From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:30:50 -0400
Subject: stable-2.02 - activation: synchronize before removing devices
Message-ID: <201904301130.x3UBUoiJ020465@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2047d405af85d0f7e0d494510f439a1e644f3285
Commit:        2047d405af85d0f7e0d494510f439a1e644f3285
Parent:        1370277ea7be06a945803a018ad9f38d681c6d67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 6 12:37:47 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:07:42 2019 +0200

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
index 89ddd41..dc2c4af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Add synchronization with udev before removing cached devices.
   Fix missing growth of _pmsmare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
   Add support for vgsplit with cached devices.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b6a188a..24455b3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3335,6 +3335,19 @@ int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv
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
index 498ec8f..eeb6c11 100644
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


