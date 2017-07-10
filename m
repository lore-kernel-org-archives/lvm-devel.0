From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:27 -0400
Subject: master - tests: aux.sh use grep -E
Message-ID: <201707101233.v6ACXRsJ022828@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=928a49a7c8f78dff4add340107ecc46e6a1b8587
Commit:        928a49a7c8f78dff4add340107ecc46e6a1b8587
Parent:        5bd09cb79dc66eac7515b93b8991eded8ac25afd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 1 09:41:14 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh use grep -E

egrep is nonstandard.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 21c94ac..6ac57d4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -545,7 +545,7 @@ teardown() {
 
 	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
 
-	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
+	dm_table | not grep -E -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
 		if dm_info suspended,name | grep -q "^Suspended:.*$prefix" ; then


