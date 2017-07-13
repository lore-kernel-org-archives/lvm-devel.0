From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 18:44:32 -0400
Subject: master - tests: aux.sh better teardown loop
Message-ID: <201707132244.v6DMiWmS013400@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e682af78789b34bbcb1706c16f629dfd93915bf9
Commit:        e682af78789b34bbcb1706c16f629dfd93915bf9
Parent:        f64f6c5e703e6d3632acf68fa353b71f452bbfc7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 14 00:27:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 00:27:55 2017 +0200

tests: aux.sh better teardown loop

We can't really sleep that much in teardown as it slows test too much.
So do a nested loop (similar to 'dmsetup remove_all') and keep
removing devices with open count == 0 as long as it works.
---
 test/lib/aux.sh |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9e0ca2c..de2e2ac 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -411,18 +411,23 @@ teardown_devs_prefixed() {
 
 	# Remove devices, start with closed (sorted by open count)
 	# Run 'dmsetup remove' in parallel
-	local need_udev_wait=0
 	rm -f REMOVE_FAILED
 	#local listdevs=( $(dm_info name,open --sort open,name | grep "$prefix.*:0") )
 	#dmsetup remove --deferred ${listdevs[@]%%:0} || touch REMOVE_FAILED
+	for i in {1..100}; do
+		local need_udev_wait=0
+		local cnt
+		while IFS=' ' read -r dm cnt; do
+			test "$cnt" -eq 0 || break
+			dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
+			need_udev_wait=1
+		done < <(dm_info name,open --separator ' ' --sort open,name | grep "$prefix")
+		test "$need_udev_wait" -eq 1 || break
+		udev_wait
+		test -f REMOVE_FAILED && break
+	done # looping till there are some removed devicess
 
-	for dm in $(dm_info name --sort open,name | grep "$prefix"); do
-		dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
-		need_udev_wait=1
-		sleep 1 # give 'dmsetup' some time to proceed with removal
-	done
 	wait
-	test "$need_udev_wait" -eq 0 || udev_wait
 
 	if test -f REMOVE_FAILED; then
 		local num_devs


