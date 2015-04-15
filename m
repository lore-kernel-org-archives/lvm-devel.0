From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:21 +0000 (UTC)
Subject: master - tests: hide error output
Message-ID: <20150415113821.CD3C760F79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d4695569d58f42dfc95feda55e463ebcbf03ffb
Commit:        5d4695569d58f42dfc95feda55e463ebcbf03ffb
Parent:        930f0aae845e65f3673d14df97e141baccf37849
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 13:10:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: hide error output

Hide error message if pid is already away.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 505d15e..c28ac7b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -218,7 +218,7 @@ kill_sleep_kill_() {
 	slow=$2
 	if test -s $pidfile ; then
 		pid=$(< $pidfile)
-		kill -TERM $pid || return 0
+		kill -TERM $pid 2>/dev/null || return 0
 		if test $slow -eq 0 ; then sleep .1 ; else sleep 1 ; fi
 		kill -KILL $pid 2>/dev/null || true
 		wait=0


