From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Apr 2015 20:22:15 +0000 (UTC)
Subject: master - test: Show all lvmetad messages (errors, warnings), not just debug+wire.
Message-ID: <20150414202215.CB53D602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e58ae7dac10345d5f461d3c349a0864f72796da
Commit:        7e58ae7dac10345d5f461d3c349a0864f72796da
Parent:        026c38ac1e2ef8a65938919233a2a8a1f55fcd7c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Apr 12 21:42:26 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 14 20:18:27 2015 +0200

test: Show all lvmetad messages (errors, warnings), not just debug+wire.

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 479c3f0..bc70cc0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -83,7 +83,7 @@ prepare_dmeventd() {
 }
 
 prepare_lvmetad() {
-	test $# -eq 0 && default_opts="-l wire,debug"
+	test $# -eq 0 && default_opts="-l all"
 	rm -f debug.log strace.log
 	# skip if we don't have our own lvmetad...
 	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip


