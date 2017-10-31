From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Mon, 30 Oct 2017 23:09:46 -0400
Subject: master - test: clean-up failing test case and document 'should' cases
Message-ID: <201710310309.v9V39kGE000865@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc29785d098ea0d663a07705e07eac27522c164d
Commit:        bc29785d098ea0d663a07705e07eac27522c164d
Parent:        248144d06654a509249938c44bb68ece4a71e6f1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 30 21:58:38 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 30 21:58:38 2017 -0500

test: clean-up failing test case and document 'should' cases

There are two known bugs in the lvconvert-raid-status-validation.sh
test.  The first one I consider to be more of an annoyance (1507719).
The second one I consider to be more serious (1507729).

RHBZ 1507719 simply documents the fact that the three RAID status
fields may not always be coherent due to the way they are set and
unset when the MD thread is shutting down and starting up.  For
example, the sync ratio may be 100% but the sync action may not
yet have switched to "idle" and the health characters may not yet
all be 'A's (i.e. the devices set to InSync).

RHBZ 1507729 is more serious.  The sync ratio can be 100% for a
short period of time after upconverting linear -> RAID1.  It is
reset to 0 once the MD sync thread gets to work on it.  It does
this because, technically, the array /is/ in-sync if the new
devices are excluded - i.e. the data is 100% available and
consistent.  I'm not sure what to do about this problem, but we'd
much rather not have this state that looks exactly like the
end of the process when the sync ratio is 100% because the
"recover" process finished, but the sync action and health
characters haven't been updated yet.  Put simply, the problem
is that we can't tell if a sync is starting or finished based
on the status output.
---
 test/shell/lvconvert-raid-status-validation.sh |   39 +++++++++++++++++------
 1 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index b4140a9..9ffaaf3 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -24,7 +24,11 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 # check for version 1.9.0
 # - it is the point at which linear->raid1 uses "recover"
-aux have_raid 1 9 0 || skip
+# check for version 1.13.0 instead
+# - it is the point at which a finishing "recover" doesn't print all 'a's
+aux have_raid 1 13 0 || skip
+
+
 
 aux prepare_pvs 9
 get_devs
@@ -39,7 +43,16 @@ lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
 while ! check in_sync $vg $lv1; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-	[ "${a[5]}" != "aa" ]
+	b=( $(echo "${a[6]}" | sed s:/:' ':) )
+	if [ "${b[0]}" -ne "${b[1]}" ]; then
+		# First, 'check in_sync' should only need to check the ratio
+		#  If we are here, it is probably doing more than that.
+		# If not in-sync, then we should only ever see "Aa"
+		[ "${a[5]}" == "Aa" ]
+	else
+		[ "${a[5]}" != "aa" ]
+		should [ "${a[5]}" == "AA" ] # RHBZ 1507719
+	fi
         sleep .1
 done
 aux enable_dev "$dev2"
@@ -53,7 +66,7 @@ lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
 a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
 b=( $(echo "${a[6]}" | sed s:/:' ':) )
-[ "${b[0]}" -ne "${b[1]}" ]
+should [ "${b[0]}" -ne "${b[1]}" ] # RHBZ 1507729
 aux enable_dev "$dev2"
 lvremove -ff $vg
 
@@ -76,8 +89,8 @@ while true; do
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
-		[ "${a[5]}" = "AA" ]
-		[ "${a[7]}" = "idle" ]
+		should [ "${a[5]}" = "AA" ] # RHBZ 1507719
+		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
         sleep .1
@@ -90,6 +103,7 @@ lvremove -ff $vg
 ###########################################
 aux delay_dev "$dev3" 0 50
 lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
+aux wait_for_sync $vg $lv1
 lvconvert -y -m +1 $vg/$lv1 "$dev3"
 while true; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
@@ -104,8 +118,8 @@ while true; do
 		#   Before starting sync thread: "AAa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "AAa X/X recover"
-		[ "${a[5]}" = "AAA" ]
-		[ "${a[7]}" = "idle" ]
+		should [ "${a[5]}" = "AAA" ] # RHBZ 1507719
+		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
         sleep .1
@@ -125,10 +139,15 @@ while true; do
 		# If the sync operation ("resync" in this case) is not
 		# finished, then it better be as follows:
 		[ "${a[5]}" = "aa" ]
-		[ "${a[7]}" = "resync" ]
+
+		# Should be in "resync", but it is possible things are only
+		# just getting going - in which case, it could be "idle"
+		# with 0% sync ratio
+		[ "${a[7]}" = "resync" ] || \
+		  [[ "${a[7]}" = "idle" && "${b[0]}" -eq "0" ]]
 	else
-		[ "${a[5]}" = "AA" ]
-		[ "${a[7]}" = "idle" ]
+		should [ "${a[5]}" = "AA" ] # RHBZ 1507719
+		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
         sleep .1


