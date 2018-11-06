From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Nov 2018 11:27:35 -0500
Subject: master - tests: fix shell quoting
Message-ID: <201811061627.wA6GRZu6020154@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a427a935493aa2d92c85f1765aaf714e073d88bc
Commit:        a427a935493aa2d92c85f1765aaf714e073d88bc
Parent:        ad0268e239a2d8445813733b70ea54a546f8b627
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 6 17:26:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 6 17:26:15 2018 +0100

tests: fix shell quoting

---
 test/shell/pvscan-autoactivate.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index b6db47a..c2fc36a 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -20,7 +20,7 @@ ONLINEDIR="$RUNDIR/lvm/pvs_online"
 _clear_online() {
 	# wait till udev is finished
 	aux udev_wait
-	rm -f "$ONLINEDIR/*"
+	rm -f "$ONLINEDIR"/*
 	test -n "${1+varset}" || touch "$ONLINEDIR/foo"
 }
 
@@ -62,9 +62,9 @@ lvchange -an $vg1
 
 _clear_online
 
-pvscan -vvvv --cache -aay "$dev1"
+pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
-pvscan -vvvv --cache -aay "$dev2"
+pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 


