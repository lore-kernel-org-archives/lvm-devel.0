From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:56 -0400
Subject: master - tests: aux.sh no mixing string
Message-ID: <201706292027.v5TKRujY026710@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b16ca76260bbfb950ee7246a249ea7e4987520af
Commit:        b16ca76260bbfb950ee7246a249ea7e4987520af
Parent:        44e530b919d72005e10970c13699c7fbfd736ce9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 07:57:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh no mixing string

Argument mixes string and array. Use * or separate argument.
---
 test/lib/aux.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 816de9a..a3e2b70 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -398,7 +398,7 @@ teardown_devs_prefixed() {
 
 	local mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) )
 	if test ${#mounts[@]} -gt 0; then
-		test "$stray" -eq 0 || echo "Removing stray mounted devices containing $prefix: ${mounts[@]}"
+		test "$stray" -eq 0 || echo "Removing stray mounted devices containing $prefix:" "${mounts[@]}"
 		if umount -fl "${mounts[@]}"; then
 			udev_wait
 		fi
@@ -461,7 +461,7 @@ teardown_devs() {
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
-			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
+			echo "Removing stray loop devices containing $COMMON_PREFIX:" "${stray_loops[@]}"
 			for i in "${stray_loops[@]}" ; do test ! -b "$i" || losetup -d "$i" || true ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
@@ -1400,7 +1400,7 @@ driver_at_least() {
 	local version=$(dmsetup version | tail -1 2>/dev/null)
 	version=${version##*:}
 	version_at_least "$version" "$@" || {
-		echo "Found driver version $version, but requested $@." >&2
+		echo "Found driver version $version, but requested" "$@" "." >&2
 		return 1
 	}
 }
@@ -1424,7 +1424,7 @@ have_thin() {
 		CONF[2]="global/thin_repair_executable = \"\""
 	fi
 	if test ${#CONF[@]} -ne 0 ; then
-		echo "TEST WARNING: Reconfiguring ${CONF[@]}"
+		echo "TEST WARNING: Reconfiguring" "${CONF[@]}"
 		lvmconf "${CONF[@]}"
 	fi
 }
@@ -1472,7 +1472,7 @@ have_cache() {
 		CONF[2]="global/cache_repair_executable = \"\""
 	fi
 	if test ${#CONF[@]} -ne 0 ; then
-		echo "TEST WARNING: Reconfiguring ${CONF[@]}"
+		echo "TEST WARNING: Reconfiguring" "${CONF[@]}"
 		lvmconf "${CONF[@]}"
 	fi
 }


