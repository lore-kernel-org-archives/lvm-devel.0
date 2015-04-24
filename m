From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:29 +0000 (UTC)
Subject: master - tests: aux for mdadm
Message-ID: <20150424224229.C66F160C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e3c135d7178426d3cd1c92a3ab9a71303b64aa2
Commit:        1e3c135d7178426d3cd1c92a3ab9a71303b64aa2
Parent:        f50229041bfc9570aeae0eef614f1e68f157802e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 25 00:37:27 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:40:02 2015 +0200

tests: aux for mdadm

Implement aux helper fce for mdadm.
---
 test/lib/aux.sh |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cc3718c..95c2f73 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -256,6 +256,8 @@ kill_listed_processes() {
 }
 
 teardown() {
+	test -f MD_DEV && cleanup_md_dev
+
 	echo -n "## teardown..."
 
 	if test -f TESTNAME ; then
@@ -387,6 +389,69 @@ cleanup_scsi_debug_dev() {
 	rm -f SCSI_DEBUG_DEV LOOP
 }
 
+prepare_md_dev() {
+	local level=$1
+	local rchunk=$2
+	local rdevs=$3
+
+	local maj=$(mdadm --version 2>&1) || skip "mdadm tool is missing!"
+	local mddev
+
+	cleanup_md_dev
+
+	rm -f debug.log strace.log MD_DEV MD_DEV_PV MD_DEVICES
+
+	# Have MD use a non-standard name to avoid colliding with an existing MD device
+	# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
+	# - newer mdadm _completely_ defers to udev to create the associated device node
+	maj=${maj##*- v}
+	maj=${maj%%.*}
+	[ "$maj" -ge 3 ] && \
+		mddev=/dev/md/md_lvm_test0 || \
+		mddev=/dev/md_lvm_test0
+
+	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --chunk $rchunk --raid-devices=$rdevs "${@:4}"
+	test -b "$mddev" || skip "mdadm has not create device!"
+
+	# LVM/DM will see this device
+	case "$DM_DEV_DIR" in
+	"/dev") readlink -f "$mddev" ;;
+	*)	cp -LR "$mddev" "$DM_DEV_DIR"
+		echo "$DM_DEV_DIR/md_lvm_test0" ;;
+	esac > MD_DEV_PV
+	echo "$mddev" > MD_DEV
+	notify_lvmetad $(< MD_DEV_PV)
+	printf "%s\n" "${@:4}" > MD_DEVICES
+	for mddev in "${@:4}"; do
+		notify_lvmetad "$mddev"
+	done
+}
+
+cleanup_md_dev() {
+	test -f MD_DEV || return 0
+
+	local IFS=$IFS_NL
+	local dev=$(< MD_DEV)
+
+	udev_wait
+	mdadm --stop "$dev" || true
+	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename $dev)"
+	notify_lvmetad $(< MD_DEV_PV)
+	for dev in $(< MD_DEVICES); do
+		mdadm --zero-superblock "$dev" || true
+		notify_lvmetad "$dev"
+	done
+	udev_wait
+	if [ -b "$mddev" ]; then
+		# mdadm doesn't always cleanup the device node
+		# sleeps offer hack to defeat: 'md: md127 still in use'
+		# see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
+		sleep 2
+		rm -f "$mddev"
+	fi
+	rm -f MD_DEV MD_DEVICES MD_DEV_PV
+}
+
 prepare_backing_dev() {
 	if test -f BACKING_DEV; then
 		BACKING_DEV=$(< BACKING_DEV)


