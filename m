From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 11:12:38 +0000 (UTC)
Subject: master - tests: play better with mdadm
Message-ID: <20150504111238.DA4066136D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a5a4f952e567ebb32e61414db62292eab81b6c7
Commit:        7a5a4f952e567ebb32e61414db62292eab81b6c7
Parent:        88421c883ebe20730e31e601d209f48b64b14ad0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 13:07:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 13:11:41 2015 +0200

tests: play better with mdadm

Manage mdadm devices on older distros is a challange.
---
 test/lib/aux.sh                     |   14 +++++++++++++-
 test/shell/pvcreate-operation-md.sh |    7 +++++++
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d0a5173..80792f5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -427,7 +427,19 @@ prepare_md_dev() {
 		mddev=/dev/md/md_lvm_test0 || \
 		mddev=/dev/md_lvm_test0
 
-	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --chunk $rchunk --raid-devices=$rdevs "${@:4}"
+	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --chunk $rchunk --raid-devices=$rdevs "${@:4}" || {
+		# Some older 'mdadm' version managed to open and close devices internaly
+		# and reporting non-exclusive access on such device
+		# let's just skip the test if this happens.
+		# Note: It's pretty complex to get rid of consequences
+		#       the following sequence avoid leaks on f19
+		# TODO: maybe try here to recreate few times....
+		mdadm --stop "$mddev" || true
+		udev_wait
+		mdadm --zero-superblock "${@:4}" || true
+		udev_wait
+		skip "Test skipped, unreliable mdadm detected!"
+	}
 	test -b "$mddev" || skip "mdadm has not created device!"
 
 	# LVM/DM will see this device
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 52a2c37..8291215 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -50,6 +50,7 @@ if aux kernel_at_least 2 6 33 ; then
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
     check pv_field "$pvdev" pe_start "1.00m"
+    pvremove "$pvdev"
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
@@ -58,6 +59,12 @@ if aux kernel_at_least 2 6 28 ; then
     sfdisk "$mddev" <<EOF
 ,,83
 EOF
+    # Wait till all partition links in udev are created
+    aux udev_wait
+
+    # Skip test if udev rule has not created proper links for partitions
+    test -b "${mddev}p1" || { ls -laR /dev ; skip "Missing partition link" ; }
+
     pvscan
     # make sure partition on MD is _not_ removed
     # - tests partition -> parent lookup via sysfs paths


