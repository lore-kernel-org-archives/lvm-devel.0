From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 16:10:46 +0000 (UTC)
Subject: master - tests: update pvmove-test
Message-ID: <20131204161046.62E6E60EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c144305d3e6b68bc9f85641a5038013fdc07b5a2
Commit:        c144305d3e6b68bc9f85641a5038013fdc07b5a2
Parent:        7c6b14b74f88a58a9589922a3fa7be18334f3936
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 17:05:44 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 17:10:31 2013 +0100

tests: update pvmove-test

Do not lock test when trying to grab cluster lock.
There seems to be still something weird in this test
so it still needs some inspection.
---
 test/shell/pvmove-restart.sh |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index c8da45e..e1d5381 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -33,16 +33,37 @@ PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
 sleep 1
 kill -9 $PVMOVE
+wait
 
 # Simulate reboot - forcibly remove related devices
 dmsetup remove $vg-$lv1
 dmsetup remove $vg-pvmove0
 
+if test -e LOCAL_CLVMD ; then
+	# giveup all clvmd locks (faster then restarting clvmd)
+	# no deactivation happen, nodes are already removed
+	vgchange -an $vg
+	# Restart clvmd
+	#kill $(cat LOCAL_CLVMD)
+	#while test -e "/var/run/clvmd.pid"; do echo -n .; sleep .1; done # wait for the pid removal
+	#aux prepare_clvmd
+fi
+
+if test -e LOCAL_LVMETAD ; then
+	# Restart lvmetad
+	kill $(cat LOCAL_LVMETAD)
+	aux prepare_lvmetad
+fi
+
 # Only PVs should be left in table...
 dmsetup table
 
 # Restart pvmove
-vgchange -ay $vg
+# use exclusive activation to have usable pvmove without cmirrord
+#vgchange -vvvv -ay $vg
+vgchange -aey $vg
+dmsetup table
+#pvmove
 
 pvmove --abort
 


