From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 21 May 2020 13:09:37 +0000 (GMT)
Subject: master - [WIP] tests: Use python single liner to generate data
Message-ID: <20200521130937.32EBC3972C1B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02397e337a5d1bb19544be4a1724aa98d1cb0008
Commit:        02397e337a5d1bb19544be4a1724aa98d1cb0008
Parent:        70a45c44e89534b6d5f9adeb04620f43453c67bf
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 6 12:10:50 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 21 15:05:02 2020 +0200

[WIP] tests: Use python single liner to generate data

---
 test/shell/integrity-dmeventd.sh | 7 ++++---
 test/shell/integrity-large.sh    | 7 ++++---
 test/shell/integrity-misc.sh     | 7 ++++---
 test/shell/integrity.sh          | 7 ++++---
 4 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 58899ca80..665e0e9a2 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -22,9 +22,10 @@ mkdir -p $mnt
 
 aux prepare_devs 6 64
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+PYTHON="$(which python3 python2 python | head -n 1)"
+$PYTHON -c "print 'A'*16384" >> fileA
+$PYTHON -c "print 'B'*16384" >> fileB
+$PYTHON -c "print 'C'*16384" >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 0c36e4d54..81fc48ec5 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -25,9 +25,10 @@ mkdir -p $mnt
 # raid1 LV needs to be extended to 512MB to test imeta being exended
 aux prepare_devs 4 600
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+PYTHON="$(which python3 python2 python | head -n 1)"
+$PYTHON -c "print 'A'*16384" >> fileA
+$PYTHON -c "print 'B'*16384" >> fileB
+$PYTHON -c "print 'C'*16384" >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 73b0a67d8..0483885ca 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -22,9 +22,10 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+PYTHON="$(which python3 python2 python | head -n 1)"
+$PYTHON -c "print 'A'*16384" >> fileA
+$PYTHON -c "print 'B'*16384" >> fileB
+$PYTHON -c "print 'C'*16384" >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 7e4f2cb0b..b01920818 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -23,9 +23,10 @@ mkdir -p $mnt
 
 aux prepare_devs 5 64
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+PYTHON="$(which python3 python2 python | head -n 1)"
+$PYTHON -c "print 'A'*16384" >> fileA
+$PYTHON -c "print 'B'*16384" >> fileB
+$PYTHON -c "print 'C'*16384" >> fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2


