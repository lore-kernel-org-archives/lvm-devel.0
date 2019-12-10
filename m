From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:58 -0500
Subject: master - tests: improve secure test
Message-ID: <94984.119121009465400477@us-mta-205.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a52855899bdbd8bc570a667a03394872667e754
Commit:        4a52855899bdbd8bc570a667a03394872667e754
Parent:        611d4107a4b3c434c4266ae6f2638927541bc9b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:43:47 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

tests: improve secure test

Validate we capture core while original task sleeps.
---
 test/shell/dmsecuretest.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index 75ad56d..0f53ea7 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -45,7 +45,9 @@ sleep .5
 dmsetup status "$DMTEST"
 
 # generate core file for running&sleeping binary
-gcore "$PID"
+gcore "$PID" | tee out
+# check we capture core while  dmsecuretest was already sleeping
+grep "nanosleep" out
 kill "$PID" || true
 wait
 
@@ -55,7 +57,7 @@ cat cmdout
 not grep "$SECURE" "core.$PID" || {
 	## cp "core.$PID" /dev/shm/core
 	rm -f "core.$PID"
-        dmsetup remove "$DMTEST"
+	should dmsetup remove "$DMTEST" # go around weird bugs
 	die "!!! Secure string $SECURE found present in core.$PID !!!"
 }
 rm -f "core.$PID"



