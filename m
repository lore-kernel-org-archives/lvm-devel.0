From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:30 +0000 (UTC)
Subject: master - tests: check there is really pvmove lv
Message-ID: <20140414110630.C80D460CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92ee51a4c367848fc17ab79848bf5ab7fb1de678
Commit:        92ee51a4c367848fc17ab79848bf5ab7fb1de678
Parent:        4d48577ab9fce971512a5c7b2faf3bfdf683f512
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 22:12:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:28 2014 +0200

tests: check there is really pvmove lv

Since the kill may take various amount of time,
(especially when running with valgrind)
check it's really pvmoved LV.

Restore initial restart of clvmd - it's currently
broken at various moments - basically killed lvm2
command may leave clvmd and confusing state leading
to reports of internal errors.
---
 test/shell/pvmove-restart.sh |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 3f9e151..26f1d74 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -39,14 +39,24 @@ wait
 dmsetup remove $vg-$lv1
 dmsetup remove $vg-pvmove0
 
+# Check we really have pvmove volume
+check lv_attr_bit type $vg/pvmove0 "p"
+
 if test -e LOCAL_CLVMD ; then
 	# giveup all clvmd locks (faster then restarting clvmd)
 	# no deactivation happen, nodes are already removed
-	vgchange -an $vg
+	#vgchange -an $vg
+	# FIXME: However above solution has one big problem
+	# as clvmd starts to abort on internal errors on various
+	# errors, based on the fact pvmove is killed -9
 	# Restart clvmd
-	#kill $(cat LOCAL_CLVMD)
-	#while test -e "/var/run/clvmd.pid"; do echo -n .; sleep .1; done # wait for the pid removal
-	#aux prepare_clvmd
+	kill $(cat LOCAL_CLVMD)
+	for i in $(seq 1 100) ; do
+		test $i -eq 100 && die "Shutdown of clvmd is too slow."
+		test -e "$CLVMD_PIDFILE" && break
+		sleep .1
+	done # wait for the pid removal
+	aux prepare_clvmd
 fi
 
 if test -e LOCAL_LVMETAD ; then
@@ -60,9 +70,8 @@ dmsetup table
 
 # Restart pvmove
 # use exclusive activation to have usable pvmove without cmirrord
-#vgchange -vvvv -ay $vg
 vgchange -aey $vg
-dmsetup table
+#sleep 2
 #pvmove
 
 pvmove --abort


