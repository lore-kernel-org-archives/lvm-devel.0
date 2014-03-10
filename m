From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:23 +0000 (UTC)
Subject: master - tests: improve wait for open
Message-ID: <20140310112723.940F2603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d913fcbd4616279829fd495e6384b661b897c6df
Commit:        d913fcbd4616279829fd495e6384b661b897c6df
Parent:        fa23234e71ce8c5270e5b45bb55556d563383dfc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 7 19:26:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

tests: improve wait for open

Add loop to detect open device from 'sleep <'
---
 test/shell/snapshot-usage.sh |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 991c18a..13be4ee 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -20,6 +20,16 @@ fill() {
 	dd if=/dev/zero of="$DM_DEV_DIR/$vg1/lvol0" bs=$1 count=1
 }
 
+# give some short time to lock file above
+wait_for_open_() {
+	for i in $(seq 1 50) ; do
+		test $(dmsetup info --noheadings -c -o open $1) -ne 0 && return
+		sleep 0.1
+	done
+
+	die "$1 expected to be openned, but it's not!"
+}
+
 cleanup_tail()
 {
 	test -z "$SLEEP_PID" || kill $SLEEP_PID
@@ -52,6 +62,7 @@ if aux target_at_least dm-snapshot 1 10 0 ; then
 	fi
 fi
 
+# Automatically activates exclusively in cluster
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
 aux extend_filter_LVMTEST
@@ -77,8 +88,7 @@ trap 'cleanup_tail' EXIT
 sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &
 SLEEP_PID=$!
 
-# give some short time to lock file above
-sleep 0.1
+wait_for_open_ "$vg1-$lv1"
 
 # Opened virtual snapshot device is not removable
 # it should retry device removal for a few seconds
@@ -173,7 +183,7 @@ lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
 check lv_field $vg1/$lv2 size "7.50p"
 lvremove -ff $vg1
 
-lvcreate -aey -V15E -l1 -n $lv1 -s $vg1
+lvcreate -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 
 vgremove -ff $vg1


