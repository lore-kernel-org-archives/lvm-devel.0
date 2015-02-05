From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:42 +0000 (UTC)
Subject: master - test: It is not an error for a test daemon to exit before teardown.
Message-ID: <20150205134342.7336560FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45e2aee8f9173cc2858da93a4bb9bc289a36bf9d
Commit:        45e2aee8f9173cc2858da93a4bb9bc289a36bf9d
Parent:        78ba413ed148f34a36e2e041947e66a681255d0d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 11:53:24 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: It is not an error for a test daemon to exit before teardown.

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3ef2da0..9241fba 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -214,7 +214,7 @@ kill_sleep_kill_() {
 	slow=$2
 	if test -s $pidfile ; then
 		pid=$(< $pidfile)
-		kill -TERM $pid
+		kill -TERM $pid || return 0
 		if test $slow -eq 0 ; then sleep .1 ; else sleep 1 ; fi
 		kill -KILL $pid 2>/dev/null || true
 		wait=0


