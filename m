From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 21 May 2020 13:34:28 +0000 (GMT)
Subject: master - test: Use printf to generate data
Message-ID: <20200521133428.14B9D3972460@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53803821de166109131c4d4e5396116f89dbb082
Commit:        53803821de166109131c4d4e5396116f89dbb082
Parent:        b5811b7c9cb27a76ef1a7e237067ef56bd7308a3
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 21 15:33:24 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 21 15:33:24 2020 +0200

test: Use printf to generate data

...to avoid unnecessary dependency on python
---
 test/shell/integrity-dmeventd.sh | 8 +++-----
 test/shell/integrity-large.sh    | 8 +++-----
 test/shell/integrity-misc.sh     | 8 +++-----
 test/shell/integrity.sh          | 8 +++-----
 4 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index a4be8c93c..ed2436aca 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -22,11 +22,9 @@ mkdir -p $mnt
 
 aux prepare_devs 6 64
 
-PYTHON="$(which python3 python2 python 2>/dev/null | head -n 1)"
-test -n "$PYTHON" || skip
-$PYTHON -c "print 'A'*16384" >> fileA
-$PYTHON -c "print 'B'*16384" >> fileB
-$PYTHON -c "print 'C'*16384" >> fileC
+printf "%0.sA" {1..16384} >> fileA
+printf "%0.sB" {1..16384} >> fileB
+printf "%0.sC" {1..16384} >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 7d8e133df..7a333c101 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -25,11 +25,9 @@ mkdir -p $mnt
 # raid1 LV needs to be extended to 512MB to test imeta being exended
 aux prepare_devs 4 600
 
-PYTHON="$(which python3 python2 python 2>/dev/null | head -n 1)"
-test -n "$PYTHON" || skip
-$PYTHON -c "print 'A'*16384" >> fileA
-$PYTHON -c "print 'B'*16384" >> fileB
-$PYTHON -c "print 'C'*16384" >> fileC
+printf "%0.sA" {1..16384} >> fileA
+printf "%0.sB" {1..16384} >> fileB
+printf "%0.sC" {1..16384} >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 735e5bf86..a176f18e0 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -22,11 +22,9 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-PYTHON="$(which python3 python2 python 2>/dev/null | head -n 1)"
-test -n "$PYTHON" || skip
-$PYTHON -c "print 'A'*16384" >> fileA
-$PYTHON -c "print 'B'*16384" >> fileB
-$PYTHON -c "print 'C'*16384" >> fileC
+printf "%0.sA" {1..16384} >> fileA
+printf "%0.sB" {1..16384} >> fileB
+printf "%0.sC" {1..16384} >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index b241c984d..6baccf00c 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -23,11 +23,9 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-PYTHON="$(which python3 python2 python 2>/dev/null | head -n 1)"
-test -n "$PYTHON" || skip
-$PYTHON -c "print 'A'*16384" >> fileA
-$PYTHON -c "print 'B'*16384" >> fileB
-$PYTHON -c "print 'C'*16384" >> fileC
+printf "%0.sA" {1..16384} >> fileA
+printf "%0.sB" {1..16384} >> fileB
+printf "%0.sC" {1..16384} >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2


