From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Nov 2017 06:06:17 -0500
Subject: master - tests: Fix common_dev_ argument handling
Message-ID: <201711281106.vASB6H6S002928@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8caca46527cd5e858b0218734ba9a1f24200d6e
Commit:        b8caca46527cd5e858b0218734ba9a1f24200d6e
Parent:        a9812ec9d3469edbe24a2d08ccb1dda209cf66a5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Nov 28 12:03:35 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 28 12:03:35 2017 +0100

tests: Fix common_dev_ argument handling

from[:[len]] arguments with missing colon assigned from to len, instead
of till_the_end_of_device.
---
 test/lib/aux.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b8a0cc0..de63167 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -912,6 +912,10 @@ common_dev_() {
 	for fromlen in "${@-0:}"; do
 		from=${fromlen%%:*}
 		len=${fromlen##*:}
+		if test "$len" = "$fromlen"; then
+			# Missing the colon at the end: empty len
+			len=
+		fi
 		test -n "$len" || len=$(( size - from ))
 		diff=$(( from - pos ))
 		if test $diff -gt 0 ; then
@@ -937,7 +941,7 @@ common_dev_() {
 
 # Replace linear PV device with its 'delayed' version
 # Could be used to more deterministicaly hit some problems.
-# Parameters: {device path} [read delay ms] [write delay ms] [offset:size]...
+# Parameters: {device path} [read delay ms] [write delay ms] [offset[:[size]]]...
 # Original device is restored when both delay params are 0 (or missing).
 # If the size is missing, the remaing portion of device is taken
 # i.e.  delay_dev "$dev1" 0 200 256:


