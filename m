From: okozina <okozina@fedoraproject.org>
Date: Wed,  6 May 2015 13:24:00 +0000 (UTC)
Subject: master - tests: do not restart lvmetad when not necessary
Message-ID: <20150506132400.4B4696108F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bbf083cd1245a2d509dc0ef4fcc8b99a07da10f
Commit:        5bbf083cd1245a2d509dc0ef4fcc8b99a07da10f
Parent:        9fc6b654f55dfe0d6c1a7fc214f9d35cb505be11
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed May 6 15:20:11 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed May 6 15:20:11 2015 +0200

tests: do not restart lvmetad when not necessary

overlooked pvmove-restart test during cleanup
---
 test/shell/pvmove-restart.sh |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index e1408bf..1ef9a24 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -75,10 +75,7 @@ if test -e LOCAL_CLVMD ; then
 	aux prepare_clvmd
 fi
 
-if test -e LOCAL_LVMETAD ; then
-	# Restart lvmetad (kill is built-in)
-	aux prepare_lvmetad
-fi
+aux notify_lvmetad "$dev1" "$dev2" "$dev3"
 
 # Only PVs should be left in table...
 dmsetup table


