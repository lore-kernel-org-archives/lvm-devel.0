From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:27 +0000 (UTC)
Subject: master - tests: improve teardown
Message-ID: <20151124103327.B9F4760DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d86c5db03acd0b74cd919f1deb6cbfd1ff86e80
Commit:        8d86c5db03acd0b74cd919f1deb6cbfd1ff86e80
Parent:        a220939d9ef77db63a1f6af5f3798573f047ab03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 23 23:17:54 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 24 11:29:28 2015 +0100

tests: improve teardown

Do not try to execute vgremove, when test has left suspended devices.
---
 test/lib/aux.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2c66f29..216dd19 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -322,8 +322,12 @@ teardown() {
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
-		vgremove -ff $cfg  \
+		if echo "$(dm_info suspended,name)" | grep -q "^Suspended:.*$prefix" ; then
+			echo "Skipping vgremove, suspended devices detected."
+		else
+			vgremove -ff $cfg  \
 			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log strace.log
+		fi
 	}
 
 	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}


