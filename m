From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:55 -0400
Subject: master - tests: correcting symlink manipulation
Message-ID: <201805240934.w4O9Yt1W002261@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89f34eaf0cc2d3916f9aa640e3a660c6c18fd3b8
Commit:        89f34eaf0cc2d3916f9aa640e3a660c6c18fd3b8
Parent:        76a45424a7b4d2e903bcb41b45b4f8cf131183ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 11:04:38 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 11:22:32 2018 +0200

tests: correcting symlink manipulation

Fix symlink and add 'verbose' pvs for a while for checking
scanning correctness.
---
 test/shell/pvcreate-operation-md.sh |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index d228ada..359113d 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -83,7 +83,7 @@ EOF
     if aux kernel_at_least 2 6 33 ; then
 	# in case the system is running without devtmpfs /dev
 	# wait here for created device node on tmpfs
-	test "$DM_DEV_DIR" != "/dev" && cp -LR "${mddev}p1" "$DM_DEV_DIR"
+	test "$DM_DEV_DIR" = "/dev" || cp -LR "${mddev}p1" "${pvdev%/*}"
 
 	pvcreate --metadatasize 128k "${pvdev}p1"
 
@@ -100,20 +100,25 @@ EOF
 	check pv_field "${pvdev}p1" pe_start $pv_align --units b --nosuffix
 
 	pvremove "${pvdev}p1"
-	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/${mddev}p1"
+	test "$DM_DEV_DIR" = "/dev" || rm -f "${pvdev}p1"
     fi
 fi
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if aux kernel_at_least 2 6 33 ; then
     # make sure we're clean for another test
-    dd if=/dev/zero of="$mddev" bs=512 count=1
+    dd if=/dev/zero of="$mddev" bs=512 count=4 conv=fdatasync
+    partprobe -s "$mddev"
     aux prepare_md_dev 0 1024 2 "$dev1" "$dev2"
     pvdev=$(< MD_DEV_PV)
 
     # optimal_io_size=2097152, minimum_io_size=1048576
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
+
+    # to see the processing of scanning
+    pvs -vvvv
+
     check pv_field "$pvdev" pe_start "2.00m"
 
     # now verify pe_start alignment override using --dataalignment


