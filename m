From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 20:36:06 +0000 (GMT)
Subject: main - tests: aux clean DM on top of MD
Message-ID: <20210323203606.4BEED385BF9E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd1f5f9a24fc906de7e6dd064ecdd8fdfa9eebda
Commit:        dd1f5f9a24fc906de7e6dd064ecdd8fdfa9eebda
Parent:        93f2d194aca4a589cd38dd8bdd99cad2945dd21c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 21:28:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 21:28:28 2021 +0100

tests: aux clean DM on top of MD

Before cleaning MD, try to remove any DM on top such MD.
Check is made through DM table check.
Maybe parse /proc/mdstat for this???
---
 test/lib/aux.sh | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 386918041..08eeac55b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -783,11 +783,21 @@ cleanup_md_dev() {
 	mddev=$(< MD_DEV)
 	base=$(basename "$mddev")
 
+	# try to find and remove any DM device on top of cleaned MD
+	# assume  /dev/mdXXX is  9:MINOR
+	local minor=${mddev##/dev/md}
+	for i in $(dmsetup table | grep 9:$minor | cut -d: -f1) ; do
+		dmsetup remove $i || {
+			dmsetup --force remove $i || true
+		}
+	done
+
 	for i in {0..10} ; do
 		grep -q "$base" /proc/mdstat || break
 		test "$i" = 0 || {
 			sleep .1
 			echo "$mddev is still present, stopping again"
+			cat /proc/mdstat
 		}
 		mdadm --stop "$mddev" || true
 		udev_wait  # wait till events are process, not zeroing to early


