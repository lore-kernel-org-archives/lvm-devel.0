From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Aug 2016 13:38:47 +0000 (UTC)
Subject: master - lvmdump: use lsblk -s and lsblk -O in lvmdump only if these options are supported
Message-ID: <20160830133847.360EF601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16ed726610eca266bc6ef03989a156862ebf3d7a
Commit:        16ed726610eca266bc6ef03989a156862ebf3d7a
Parent:        52d1ddd601d278821d69aa35914e0db18f018749
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 30 15:33:50 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 30 15:38:34 2016 +0200

lvmdump: use lsblk -s and lsblk -O in lvmdump only if these options are supported

The lsblk is just a nice helper here - it's not crucial for lvmdump so
do best effort here and use the most we can from current version of
lsblk that is installed on system. The lsblk -s option was added a bit
later after lsblk introduction and lsblk -O support even more later -
so if these are not available, use only pure lsblk output without any
extras.
---
 WHATS_NEW          |    1 +
 scripts/lvmdump.sh |   13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad3d174..3f7eaf1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Use lsblk -s and lsblk -O in lvmdump only if these options are supported.
   Fix number of stripes shown in lvcreate raid10 message when too many.
   Do not monitor cache-pool metadata when LV is just being cleared.
   Add allocation/cache_pool_max_chunks to prevent misuse of cache target.
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index d13a69b..85f8e5c 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -28,6 +28,7 @@ PS=ps # need alx
 SED=sed
 DD=dd
 CUT=cut
+GREP=grep
 DATE=date
 BASENAME=basename
 UDEVADM=udevadm
@@ -259,8 +260,14 @@ if (( $sysreport )); then
 	if test -z "LSBLK"; then
 		myecho "WARNING: lsblk not found"
 	else
-		log "$LSBLK -O >> \"$sysreport_dir/lsblk\""
-		log "$LSBLK -s >> \"$sysreport_dir/lsblk_s\""
+		if $LSBLK --help | $GREP -- --output-all >/dev/null; then
+			log "$LSBLK -O >> \"$sysreport_dir/lsblk_O\""
+		else
+			log "$LSBLK >> \"$sysreport_dir/lsblk\""
+		fi
+		if $LSBLK --help | $GREP -- --inverse >/dev/null; then
+			log "$LSBLK -s >> \"$sysreport_dir/lsblk_s\""
+		fi
 	fi
 
 	if test -z "$SYSTEMCTL"; then
@@ -281,7 +288,7 @@ if (( $sysreport )); then
 						   lvm2-activation-net.service \
 						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
 		log "$SYSTEMCTL list-units -l -a --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
-		for unit in $(cat $sysreport_dir/systemd_unit_list | grep lvm2-pvscan | cut -d " " -f 1); do
+		for unit in $(cat $sysreport_dir/systemd_unit_list | $GREP lvm2-pvscan | cut -d " " -f 1); do
 			log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise $unit >> \"$sysreport_dir/systemd_lvm2_pvscan_service_status\""
 		done
 	fi


