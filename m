From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Nov 2018 09:31:27 -0500
Subject: master - devicemapper: retry mirror leg deactivation
Message-ID: <201811121431.wACEVRtT028880@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=836dc9876b58ae275b87cedebd11991639cbd019
Commit:        836dc9876b58ae275b87cedebd11991639cbd019
Parent:        38770db19b3c77e83e4e451f12ba3cd134c09f05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 12 15:22:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 12 15:30:40 2018 +0100

devicemapper: retry mirror leg deactivation

This could be seen as continuation of
6cee8f1b063dcf5d809e14de38ba489ce5b8f562.
Some test maching with old udev system shows problem,
where udev 'jumps on' leg device after mirror target
releases its legs -  since udev does not (in this old case) skips
such device from scanning - it opens device - and this prevent
leg device to be deactivated - effectively such device stays
'leaked' in DM table invisibly to lvm2 command.

So to 'combat' this issue - if the device has '_mimage' in its name,
the retry of deactivation is automatically assumed.

NOTE: wider impact is unexpected - as it's touching only old mirror
target which is nowadays replaced with 'raid'.

In case there will be some problem identified - probably both patches
should be reverted.
---
 device_mapper/libdm-deptree.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 06f10ae..c134489 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1764,7 +1764,12 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 
 		if (info.open_count) {
 			/* Skip internal non-toplevel opened nodes */
-			if (level)
+			/* On some old udev systems without corrrect udev rules
+			 * this hack avoids 'leaking' active _mimageX legs after
+			 * deactivation of mirror LV. Other suffixes are not added
+			 * since it's expected newer systems with wider range of
+			 * supported targets also use better udev */
+			if (level && !strstr(name, "_mimage"))
 				continue;
 
 			/* When retry is not allowed, error */


