From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 13 Oct 2015 10:23:04 +0000 (UTC)
Subject: master - wiping: make libblkid detect all copies of the same signature if use_blkid_wiping=1
Message-ID: <20151013102304.484F66112C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ac81657e5d312b72d746bc7cf22a4e6bb5b1609
Commit:        5ac81657e5d312b72d746bc7cf22a4e6bb5b1609
Parent:        5bd63df237bc3426d1ebd41b103430063846b3ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 13 12:18:04 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 13 12:22:09 2015 +0200

wiping: make libblkid detect all copies of the same signature if use_blkid_wiping=1

Some signatures are spread around the disk in several copies, mainly for
backup. Make libblkid to detect these extra copies - there was missing
"blkid_probe_step_back" fn call after successful wipe of previous signature
copy.

An example with FAT table which has copies:

$ mkfs.vfat /dev/sda1

Before this patch:

$ pvcreate /dev/sda1
WARNING: vfat signature detected on /dev/sda1 at offset 54. Wipe it? [y/n]: y
  Wiping vfat signature on /dev/sda1.
  Physical volume "/dev/sda1" successfully created

With this patch applied:

$ pvcreate /dev/sda1
WARNING: vfat signature detected on /dev/sda1 at offset 54. Wipe it? [y/n]: y
  Wiping vfat signature on /dev/sda1.
WARNING: vfat signature detected on /dev/sda1 at offset 0. Wipe it? [y/n]: y
  Wiping vfat signature on /dev/sda1.
WARNING: vfat signature detected on /dev/sda1 at offset 510. Wipe it? [y/n]: y
  Wiping vfat signature on /dev/sda1.
  Physical volume "/dev/sda1" successfully created
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5fa6e7f..f683456 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
   Fix vgimportclone with -n to not add number unnecessarily to base VG name.
   Cleanup vgimportclone script and remove dependency on awk, grep, cut and tr.
   Add vg_missing_pv_count report field to report number of missing PVs in a VG.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 25f11d1..1d03024 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -651,8 +651,13 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 						 BLKID_SUBLKS_BADCSUM);
 
 	while (!blkid_do_probe(probe)) {
-		if ((r_wipe = _blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force)) == 1)
+		if ((r_wipe = _blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force)) == 1) {
 			(*wiped)++;
+			if (blkid_probe_step_back(probe)) {
+				log_error("Failed to step back blkid probe to check just wiped signature.");
+				goto out;
+			}
+		}
 		/* do not count excluded types */
 		if (r_wipe != 2)
 			found++;


