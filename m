From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:09 +0000 (GMT)
Subject: main - tests: check mixing striped with error and zero
Message-ID: <20210318181509.7D54C3844031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c06325263f6e8bbba3b240295ba766a7769735a7
Commit:        c06325263f6e8bbba3b240295ba766a7769735a7
Parent:        1880b573f3b69deb561251dea003b5be7ff59ab3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 16:00:01 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:57:45 2021 +0100

tests: check mixing striped with error and zero

---
 test/shell/error-usage.sh | 11 +++++++++++
 test/shell/zero-usage.sh  |  9 +++++++++
 2 files changed, 20 insertions(+)

diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 59502480c..f8a561a37 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -32,4 +32,15 @@ check lv_field $vg/$lv1 seg_size_pe "4"   # 4 * 512 => 2M
 # FIXME should we print info we are ignoring stripping?
 lvextend -L+1 -I64 -i2 $vg/$lv1
 
+# We support mixing error with zero & linear targets
+lvextend -L+1 --type zero $vg/$lv1
+lvextend -L+1 --type linear $vg/$lv1
+lvextend -L+1 --type striped $vg/$lv1
+lvextend -L+1 --type error $vg/$lv1
+
+# 4 segments:  error 3m, zero 1m, linear 2m, error 1m
+lvs -o+segtype,seg_size $vg
+check lv_field $vg/$lv1 seg_count "4"
+check lv_field $vg/$lv1 size "7.00m"
+
 vgremove -ff $vg
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index 53ffbe499..063f01818 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -34,4 +34,13 @@ check lv_field $vg/$lv1 segtype "zero"
 check lv_field $vg/$lv1 seg_count "1"
 check lv_field $vg/$lv1 seg_size_pe "4"   # 4 * 512
 
+lvextend -L+1 --type error $vg/$lv1
+lvextend -L+1 --type linear $vg/$lv1
+lvextend -L+1 --type striped $vg/$lv1
+lvextend -L+1 --type zero $vg/$lv1
+
+lvs -o+segtype,seg_size $vg
+check lv_field $vg/$lv1 seg_count "4"
+check lv_field $vg/$lv1 size "6.00m"
+
 vgremove -ff $vg


