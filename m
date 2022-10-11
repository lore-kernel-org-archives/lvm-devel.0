From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Oct 2022 17:49:42 +0000 (GMT)
Subject: main - tests: add comments to fsadm-renamed
Message-ID: <20221011174942.DC1943858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc52e87f06959f542ea78b75df104bc6c85fd973
Commit:        fc52e87f06959f542ea78b75df104bc6c85fd973
Parent:        657df00c9615ea5abb6faf4c21f01f90de17b207
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 11 11:28:19 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 11 12:48:31 2022 -0500

tests: add comments to fsadm-renamed

to explain the what and why of the steps that are
not obvious
---
 test/shell/fsadm-renamed.sh | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 5e2e2ed78..698b143cf 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -83,29 +83,44 @@ echo "$i"
 #   https://github.com/systemd/systemd/pull/2017
 aux udev_wait
 
+# mount /dev/test/lv1 on /mnt
 mount "$dev_vg_lv" "$mount_dir"
 
 aux udev_wait
 
+# rename lv1 to lv1_renamed, now /dev/test/lv1_renamed is mounted on /mnt,
+# but "df" and "mount" commands will still show /dev/test/lv1 mounted on /mnt.
 lvrename $vg_lv $vg_lv_ren
 
 check_mounted
 
 # fails on renamed LV
+# lvextend -r test/lv1_renamed succeeds in extending the LV (as lv1_renamed),
+# but xfs_growfs /dev/test/lv1_renamed fails because it doesn't recognize
+# that device is mounted, because the old lv name reported as being mounted.
 fail lvresize -y -L+10M -r $vg_lv_ren
 
 # fails on unknown mountpoint  (FIXME: umount)
 not umount "$dev_vg_lv"
 
+# create a new LV with the previous name of the renamed lv
 lvcreate -L300 -n $lv1 $vg
 "$i" $MKFS_ARGS "$dev_vg_lv"
 
 aux udev_wait
 
+# mount the new lv on a dir with a similar name as the other
+# now df will show
+# /dev/mapper/test-lv1 ... /mnt
+# /dev/mapper/test-lv1 ... /mnt $SPACE dir
 mount "$dev_vg_lv" "$mount_dolar_dir"
 
 check_mounted
 
+# try to resize the LV that was renamed:  lvextend -r test/lv1_renamed
+# this succeeds in extending the LV (lv1_renamed), but xfs_growfs fails
+# for the same reason as above, i.e. mount doesn't show the lv1_renamed
+# device is mounted anywhere.
 not lvresize -L+10M -r $vg_lv_ren
 
 umount "$mount_dir"

