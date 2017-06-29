From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:24 -0400
Subject: master - lvmdump: drop extra $
Message-ID: <201706292026.v5TKQOFo025823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0740f831c4787fbb98a9a7db5ca2f3c0bfdcf6d
Commit:        a0740f831c4787fbb98a9a7db5ca2f3c0bfdcf6d
Parent:        e08e714b68cce5b46fe47af7716a6d5236f5c683
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:56:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: drop extra $

$/${} is unnecessary on arithmetic variables.
---
 scripts/lvmdump.sh.in |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 143b819..611dda6 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -139,7 +139,7 @@ warnings
 myecho "Creating dump directory: $dir"
 echo " "
 
-if (( $advanced )); then
+if (( advanced )); then
 	myecho "Gathering LVM volume info..."
 
 	myecho "  vgscan..."
@@ -158,7 +158,7 @@ if (( $advanced )); then
 	log "\"$LVM\" vgs -v >> \"$dir/vgs\" 2>> \"$log\""
 fi
 
-if (( $clustered )); then
+if (( clustered )); then
 	myecho "Gathering cluster info..."
 
 	{
@@ -234,7 +234,7 @@ myecho "Gathering /sys/block listing..."
 log "$LS -laR /sys/block >> \"$dir/sysblock_listing\"  2>> \"$log\""
 log "$LS -laR /sys/devices/virtual/block >> \"$dir/sysblock_listing\"  2>> \"$log\""
 
-if (( $metadata )); then
+if (( metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."
 
 	log "$MKDIR -p \"$dir/metadata\""
@@ -252,7 +252,7 @@ if (( $metadata )); then
 	done
 fi
 
-if (( $sysreport )); then
+if (( sysreport )); then
 	myecho "Gathering system info..."
 
 	sysreport_dir="$dir/sysreport"
@@ -301,7 +301,7 @@ if (( $sysreport )); then
 	fi
 fi
 
-if (( $udev )); then
+if (( udev )); then
 	myecho "Gathering udev info..."
 
 	udev_dir="$dir/udev"
@@ -315,7 +315,7 @@ if (( $udev )); then
 	log "$CP -RL --preserve=all /lib/udev/rules.d \"$udev_dir/rules_lib\" 2>> \"$log\""
 fi
 
-if (( $lvmetad )); then
+if (( lvmetad )); then
     (echo 'request="dump"'; echo '##') | {
 	if type -p "$SOCAT" >& /dev/null; then
 	    echo "$SOCAT unix-connect:$LVMETAD_SOCKET -" >> "$log"
@@ -331,7 +331,7 @@ if (( $lvmetad )); then
     } > "$dir/lvmetad.txt"
 fi
 
-if (( $lvmpolld )); then
+if (( lvmpolld )); then
     (echo 'request="dump"'; echo '##') | {
 	if type -p "$SOCAT" >& /dev/null; then
 	    echo "$SOCAT unix-connect:$LVMPOLLD_SOCKET -" >> "$log"


