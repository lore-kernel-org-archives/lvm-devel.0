From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 10 Jul 2015 14:23:46 +0000 (UTC)
Subject: master - test: Fix syntax error in prepare_devs
Message-ID: <20150710142346.C7CF260EF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47ac6a1a2eedd191ac69dea45490f8104b596fc5
Commit:        47ac6a1a2eedd191ac69dea45490f8104b596fc5
Parent:        3d2c4dc034d685a8d1cf07131a2194ac925852ef
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jul 10 14:59:15 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jul 10 16:15:15 2015 +0200

test: Fix syntax error in prepare_devs

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 459e7f1..f870501 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -545,7 +545,7 @@ prepare_devs() {
 	# sanlock requires more space for the internal sanlock lv
 	# This could probably be lower, but what are the units?
 	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
-		devsize = 1024
+		devsize=1024
 	fi
 
 	touch DEVICES


