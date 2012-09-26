From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:08 +0000 (UTC)
Subject: master - TEST: Workaround for lvmetad vs inconsistent metadata.
Message-ID: <20120926175608.22366A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8e287cca21feda34ff261e449e8d5a89a9490e9
Commit:        f8e287cca21feda34ff261e449e8d5a89a9490e9
Parent:        9f96286c29897ba9ac5c7c2f167d0f33ebaa93d4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Sep 20 01:57:55 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

TEST: Workaround for lvmetad vs inconsistent metadata.

---
 test/shell/inconsistent-metadata.sh |    1 +
 test/shell/unlost-pv.sh             |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index b5ef450..9f4ffd2 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -37,6 +37,7 @@ test -e LOCAL_LVMETAD && cache="--cache"
 init
 vgscan $cache 2>&1 | tee cmd.out
 grep "Inconsistent metadata found for VG $vg" cmd.out
+test -e LOCAL_LVMETAD && vgrename $vg foo && vgrename foo $vg # trigger a write
 vgscan $cache 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index c7a1412..962fe22 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -15,26 +15,30 @@ check_() {
 	# vgscan needs --cache option for direct scan if lvmetad is used
 	test -e LOCAL_LVMETAD && cache="--cache"
 	vgscan $cache 2>&1 | tee vgscan.out
-	grep "Inconsistent metadata found for VG $vg" vgscan.out
-	vgscan $cache 2>&1 | tee vgscan.out
-	not grep "Inconsistent metadata found for VG $vg" vgscan.out
+	$1 grep "Inconsistent metadata found for VG $vg" vgscan.out
 }
 
 aux prepare_vg 3
 
 lvcreate -m 1 -l 1 -n mirror $vg
-lvchange -a n $vg/mirror
+lvchange -a n $vg
 
 # try orphaning a missing PV (bz45867)
 aux disable_dev "$dev1"
 vgreduce --removemissing --force $vg
 aux enable_dev "$dev1"
+
 check_
+test -e LOCAL_LVMETAD && pvcreate -f "$dev1"
+check_ not
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
 vgextend $vg "$dev1"
+lvcreate -l 1 -n boo -a n --zero n $vg
 aux disable_dev "$dev1"
 lvremove $vg/mirror
 aux enable_dev "$dev1"
 check_
+test -e LOCAL_LVMETAD && lvremove $vg/boo # FIXME trigger a write :-(
+check_ not


