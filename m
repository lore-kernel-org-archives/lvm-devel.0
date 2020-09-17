From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Sep 2020 22:36:06 +0000 (GMT)
Subject: master - tests: also use sed to shorten log output
Message-ID: <20200917223606.9A41C393C843@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4137412bf64843578fd116f443d6586a0cffbed
Commit:        a4137412bf64843578fd116f443d6586a0cffbed
Parent:        8d40859e29c03c867c788c4927076b4192192214
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 00:31:59 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 00:31:59 2020 +0200

tests: also use sed to shorten log output

---
 test/shell/integrity-dmeventd.sh | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 0a081599f..a8c41803e 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -23,8 +23,9 @@ mkdir -p $mnt
 aux prepare_devs 6 64
 
 printf "%0.sA" {1..16384} >> fileA
-printf "%0.sB" {1..16384} >> fileB
-printf "%0.sC" {1..16384} >> fileC
+# instead of long debug 'printf' log use 'sed' and just replace A->B|C
+sed -e 's,A,B,g' fileA > fileB
+sed -e 's,A,C,g' fileA > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2


