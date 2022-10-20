From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Oct 2022 20:11:36 +0000 (GMT)
Subject: main - lvmdbusd: Always leverage udev
Message-ID: <20221020201136.618A9384BC2B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a1c73ddbe35be24cde02f77bac7e3b8b6d92242
Commit:        8a1c73ddbe35be24cde02f77bac7e3b8b6d92242
Parent:        5a6ae2d4d8e65452bbdddd9a3cbd317e142fb9f1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 18 12:30:09 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Oct 20 15:10:35 2022 -0500

lvmdbusd: Always leverage udev

Previously we utilized udev until we got a dbus notification from lvm
command line tools.  This however misses the case where something outside
of lvm clears the signatures on a block device and we fail to refresh the
state of the daemon.  Change the behavior so we always monitor udev events,
but ignore those udev events that pertain to lvm members.

Note: --udev command line option no longer does anything and simply
outputs a message that it's no longer used.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1967171
---
 daemons/lvmdbusd/main.py      |  3 ++-
 daemons/lvmdbusd/manager.py   |  6 ------
 daemons/lvmdbusd/udevwatch.py | 20 +++++++++++++-------
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 662d7569f..e869bcec3 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -125,7 +125,8 @@ def process_args():
 	# Add udev watching
 	if args.use_udev:
 		# Make sure this msg ends up in the journal, so we know
-		log_msg('Utilizing udev to trigger updates')
+		log_msg('The --udev option is no longer supported,'
+				'the daemon always uses a combination of dbus notify from lvm tools and udev')
 
 	return args
 
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 9c41f0fc3..c6fb11d76 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -203,12 +203,6 @@ class Manager(AutomatedProperties):
 		in_signature='s', out_signature='i')
 	def ExternalEvent(self, command):
 		utils.log_debug("ExternalEvent %s" % command)
-		# If a user didn't explicitly specify udev, we will turn it off now.
-		if not cfg.args.use_udev:
-			if udevwatch.remove():
-				utils.log_msg("ExternalEvent received, disabling "
-								"udev monitoring")
-				# We are dependent on external events now to stay current!
 		r = RequestEntry(
 			-1, Manager._external_event, (command,), None, None, False)
 		cfg.worker_q.put(r)
diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index f9b3e4ad1..237ff17e8 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -52,20 +52,26 @@ def filter_event(action, device):
 	# when appropriate.
 	refresh = False
 
+	# Ignore everything but change
+	if action != 'change':
+		return
+
 	if 'ID_FS_TYPE' in device:
 		fs_type_new = device['ID_FS_TYPE']
-
 		if 'LVM' in fs_type_new:
-			refresh = True
+			# Let's skip udev events for LVM devices as we should be handling them
+			# with the dbus notifications.
+			pass
 		elif fs_type_new == '':
 			# Check to see if the device was one we knew about
 			if 'DEVNAME' in device:
-				found = cfg.om.get_object_by_lvm_id(device['DEVNAME'])
-				if found:
+				if cfg.om.get_object_by_lvm_id(device['DEVNAME']):
 					refresh = True
-
-	if 'DM_LV_NAME' in device:
-		refresh = True
+	else:
+		# This handles the wipefs -a path
+		if not refresh and 'DEVNAME' in device:
+			if cfg.om.get_object_by_lvm_id(device['DEVNAME']):
+				refresh = True
 
 	if refresh:
 		udev_add()

