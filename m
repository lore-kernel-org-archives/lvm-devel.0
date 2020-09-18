From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 Sep 2020 15:31:15 +0000 (GMT)
Subject: master - tests: printf to awk
Message-ID: <20200918153115.B919E396EC88@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b07ae55f1a1e7ad33b2fb0067112ed074f30bf4
Commit:        4b07ae55f1a1e7ad33b2fb0067112ed074f30bf4
Parent:        9fbcba1c40eb5256f262e3442ade42e53dcb88d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 17:27:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:30:45 2020 +0200

tests:  printf to awk

Shorten trace logs.
---
 test/shell/integrity-misc.sh | 8 +++++---
 test/shell/integrity.sh      | 9 +++++----
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index e025c93d2..4ebf42213 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -22,9 +22,11 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-printf "%0.sA" {1..16384} >> fileA
-printf "%0.sB" {1..16384} >> fileB
-printf "%0.sC" {1..16384} >> fileC
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index f2acc1ee4..6af12f23f 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -23,10 +23,11 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-printf "%0.sA" {1..16384} >> fileA
-# instead of long debug 'printf' log use 'sed' and just replace A->B|C
-sed -e 's,A,B,g' fileA > fileB
-sed -e 's,A,C,g' fileA > fileC
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2


