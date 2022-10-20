From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Oct 2022 20:11:38 +0000 (GMT)
Subject: main - lvmdbusd: Handle PV signature copy
Message-ID: <20221020201138.A1952384BC20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94dde5769984c5ede211d122cc7392a26f8dbef4
Commit:        94dde5769984c5ede211d122cc7392a26f8dbef4
Parent:        736547e7bb306236e1ea6f4d8d9185ee0ab69638
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 20 10:46:51 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Oct 20 15:10:35 2022 -0500

lvmdbusd: Handle PV signature copy

If something manually copies a PV signature to a block device we will
miss it.  Handle this case too.
---
 daemons/lvmdbusd/udevwatch.py | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index 237ff17e8..7ee7c9d1c 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -59,9 +59,13 @@ def filter_event(action, device):
 	if 'ID_FS_TYPE' in device:
 		fs_type_new = device['ID_FS_TYPE']
 		if 'LVM' in fs_type_new:
-			# Let's skip udev events for LVM devices as we should be handling them
-			# with the dbus notifications.
-			pass
+			# If we get a lvm related udev event for a block device
+			# we don't know about, it's either a pvcreate which we
+			# would handle with the dbus notification or something
+			# copied a pv signature onto a block device, this is
+			# required to catch the latter.
+			if not cfg.om.get_object_by_lvm_id(device['DEVNAME']):
+				refresh = True
 		elif fs_type_new == '':
 			# Check to see if the device was one we knew about
 			if 'DEVNAME' in device:

