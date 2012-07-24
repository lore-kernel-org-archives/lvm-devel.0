From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 24 Jul 2012 19:22:06 +0000 (UTC)
Subject: master - TEST: Add library functions for checking and waiting for sync
Message-ID: <20120724192206.980D42304@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=753cb9204d24ceb4d9f8184ceb4c0262b9aacb42
Commit:        753cb9204d24ceb4d9f8184ceb4c0262b9aacb42
Parent:        5e36b86c46f04eddae2d4b1f826e1f24995b3636
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 24 14:17:54 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 24 14:17:54 2012 -0500

TEST: Add library functions for checking and waiting for sync

Add 'in_sync' and 'wait_for_sync' to test and wait for synchronization
of a mirror or RAID logical volume.
---
 test/lib/aux.sh   |   12 ++++++++++++
 test/lib/check.sh |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 91f54c9..4128f30 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -479,6 +479,18 @@ udev_wait() {
 	fi
 }
 
+# wait_for_sync <VG/LV>
+wait_for_sync() {
+	local i
+	for i in {1..500} ; do
+		check in_sync $1 $2 && return
+		sleep .2
+	done
+
+	echo "Sync is taking too long - assume stuck"
+	return 1
+}
+
 #
 # Check wheter kernel [dm module] target exist
 # at least in expected version
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 9c78728..95bba4b 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -151,6 +151,51 @@ linear() {
 			$(lvl $lv -o+devices)
 }
 
+# in_sync <VG> <LV>
+# Works for "mirror" and "raid*"
+in_sync() {
+	local a
+	local b
+	local idx
+	local type
+	local lvm_name="$1/$2"
+	local dm_name=$(echo $lvm_name | sed s:-:--: | sed s:/:-:)
+
+	if ! a=(`dmsetup status $dm_name`); then
+		die "Unable to get sync status of $1"
+	elif [ ${a[2]} = "snapshot-origin" ]; then
+		if ! a=(`dmsetup status ${dm_name}-real`); then
+			die "Unable to get sync status of $1"
+		fi
+	fi
+
+	if [ ${a[2]} = "raid" ]; then
+		# Last argument is the sync ratio for RAID
+		idx=$((${#a[@]} - 1))
+		type=${a[3]}
+	elif [ ${a[2]} = "mirror" ]; then
+		# 4th Arg tells us how far to the sync ratio
+		idx=$((${a[3]} + 4))
+		type=${a[2]}
+	else
+		die "Unable to get sync ratio for target type '${a[2]}'"
+	fi
+
+	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
+
+	if [ ${b[0]} != ${b[1]} ]; then
+		echo "$lvm_name ($type) is not in-sync"
+		return 1
+	fi
+
+	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
+		die "$lvm_name in-sync, but 'a' characters in health status"
+	fi
+
+	echo "$lvm_name ($type) is in-sync"
+	return 0
+}
+
 active() {
 	local lv=$1/$2
 	(get lv_field $lv attr | grep "^....a...$" >/dev/null) || \


