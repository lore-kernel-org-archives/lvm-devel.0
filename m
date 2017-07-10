From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:17 -0400
Subject: master - tests: drop wc -l when grep -c works
Message-ID: <201707101233.v6ACXHkb022756@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efcbad25ee85c2f672ba8f4e30be9fe07d6c34a7
Commit:        efcbad25ee85c2f672ba8f4e30be9fe07d6c34a7
Parent:        e55bae2b2caa67d6b6ee1346fd5cebfe67698677
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 2 21:56:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop wc -l when grep -c works

---
 test/shell/pv-duplicate-uuid.sh   |    2 +-
 test/shell/thin-dmeventd-warns.sh |    2 +-
 test/shell/vgcfgbackup-usage.sh   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index d1664a4..43eb830 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -35,7 +35,7 @@ pvs -o+uuid 2>&1 | tee out
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep $UUID1 main | wc -l) -eq 1
+test "$(grep -c $UUID1 main)" -eq 1
 
 COUNT=$(grep --count "was already found" warn)
 [ "$COUNT" -eq 2 ]
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index 29d3c4f..d874102 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -29,7 +29,7 @@ wait_warn_() {
 
 	for i in $(seq 1 7)
 	do
-		test $(egrep "WARNING: Thin pool.*is now" debug.log_DMEVENTD_out | wc -l) -eq $1 && return 0
+		test "$(grep -E -c "WARNING: Thin pool.*is now" debug.log_DMEVENTD_out)" -eq "$1" && return 0
 		sleep 2
 	done
 
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 6183490..6bf6cea 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -47,7 +47,7 @@ invalid vgcfgrestore -f "bak-$vg1" $vg1-inv at lid
 invalid vgcfgrestore -f "bak-$vg1" $vg1 $vg2
 
 vgcfgrestore -l $vg1 | tee out
-test $(grep Description out | wc -l) -eq 2
+test "$(grep -c Description out)" -eq 2
 
 vgcfgrestore -l -f "bak-$vg1" $vg1
 


