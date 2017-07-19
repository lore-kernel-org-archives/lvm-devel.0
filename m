From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jul 2017 06:23:59 -0400
Subject: master - tests: aux.sh fix wait_pvmove_lv_ready
Message-ID: <201707191023.v6JANxH6015015@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86d7adc2a587228f30c4fbceed82005ccd7b0efb
Commit:        86d7adc2a587228f30c4fbceed82005ccd7b0efb
Parent:        43dbfee32a0758c84b54aff41d1f91b2c974117f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 12:15:39 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 19 12:15:39 2017 +0200

tests: aux.sh fix wait_pvmove_lv_ready

Ignore error if the 'queried' LV is still not available
(since 'get' now properly returns failure when LV is missing)
---
 test/lib/aux.sh |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7ab3885..e620e81 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -488,15 +488,16 @@ teardown_devs() {
 }
 
 kill_sleep_kill_() {
-	pidfile=$1
-	slow=$2
+	local pidfile=$1
+	local slow=$2
+
 	if test -s "$pidfile" ; then
 		pid=$(< "$pidfile")
 		rm -f "$pidfile"
 		kill -TERM "$pid" 2>/dev/null || return 0
 		if test "$slow" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
 		kill -KILL "$pid" 2>/dev/null || true
-		wait=0
+		local wait=0
 		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .5
 			wait=$(( wait + 1 ))
@@ -1085,7 +1086,7 @@ prepare_vg() {
 }
 
 extend_filter() {
-	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\[:[ \"$rx\", :")
 	done
@@ -1097,7 +1098,7 @@ extend_filter_LVMTEST() {
 }
 
 hide_dev() {
-	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\[:[ \"r|$dev|\", :")
 	done
@@ -1105,7 +1106,7 @@ hide_dev() {
 }
 
 unhide_dev() {
-	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\"r|$dev|\", ::")
 	done
@@ -1556,8 +1557,7 @@ check_lvmpolld_init_rq_count() {
 	local ret
 	ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
 	test "$ret" -eq "$1" || {
-		echo "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
-		return 1
+		die "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
 	}
 }
 
@@ -1570,9 +1570,11 @@ wait_pvmove_lv_ready() {
 		while : ; do
 			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
 			test -n "$lvid" || {
-				lvid=$(get lv_field "${1//-//}" vg_uuid,lv_uuid -a 2>/dev/null)
-				lvid=${lvid//\ /}
-				lvid=${lvid//-/}
+				# wait till wanted LV really appears
+				lvid=$(get lv_field "${1//-//}" vg_uuid,lv_uuid -a 2>/dev/null) && {
+					lvid=${lvid//\ /}
+					lvid=${lvid//-/}
+				}
 			}
 			test -z "$lvid" || {
 				lvmpolld_dump > lvmpolld_dump.txt
@@ -1615,6 +1617,9 @@ hold_device_open() {
 
 # return total memory size in kB units
 total_mem() {
+	local a
+	local b
+
 	while IFS=":" read -r a b ; do
 		case "$a" in MemTotal*) echo "${b%% kB}" ; break ;; esac
 	done < /proc/meminfo


