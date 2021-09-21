From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:50:57 +0000 (GMT)
Subject: main - shellcheck: tests fixes
Message-ID: <20210921195057.2A6E23858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bd99d55b023f1e105bea6033aa57db3987f2ba5
Commit:        5bd99d55b023f1e105bea6033aa57db3987f2ba5
Parent:        130993bab1a6fe40c781bff396e13b56a2b2768b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 16:59:21 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

shellcheck: tests fixes

Correcting some shell problems.
---
 test/shell/integrity.sh         | 2 +-
 test/shell/lvcreate-thin-big.sh | 4 ++--
 test/shell/pe-align.sh          | 2 --
 test/shell/pvmove-resume-2.sh   | 2 +-
 4 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 80ff919b2..293cde84a 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -623,7 +623,7 @@ vgremove -ff $vg
 # Repeat many of the tests above using bitmap mode
 
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1 "$dev2"
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 254903548..bdb594218 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -31,11 +31,11 @@ vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Size 0 is not valid
 invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
-lvcreate -Zn -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>&1 >out
+lvcreate -Zn -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 >out 2>&1
 grep -i "minimal" out
 # FIXME: metadata allocation fails, if PV doesn't have at least 16GB
 # i.e. pool metadata device cannot be multisegment
-lvcreate -Zn -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>&1 >out
+lvcreate -Zn -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 >out 2>&1
 grep "maximum" out
 check lv_field $vg/pool1_tmeta size "2.00m"
 check lv_field $vg/pool2_tmeta size "<15.88g"
diff --git a/test/shell/pe-align.sh b/test/shell/pe-align.sh
index c547188c9..701510841 100644
--- a/test/shell/pe-align.sh
+++ b/test/shell/pe-align.sh
@@ -1,4 +1,3 @@
-
 #!/usr/bin/env bash
 
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
@@ -141,4 +140,3 @@ check pv_field "$dev1" ba_start 384.00k --units k
 check pv_field "$dev1" ba_size  256.00k --units k
 check pv_field "$dev1" pe_start 640.00k --units k
 pvremove "$dev1"
-
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 1ba4bc662..3dea74364 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -53,7 +53,7 @@ test_pvmove_resume() {
 		# errors, based on the fact pvmove is killed -9
 		# Restart clvmd
 		kill "$(< LOCAL_CLVMD)"
-		for i in {1 100} ; do
+		for i in {1..100} ; do
 			test $i -eq 100 && die "Shutdown of clvmd is too slow."
 			test -e "$CLVMD_PIDFILE" || break
 			sleep .1


