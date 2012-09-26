From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:30 +0000 (UTC)
Subject: master - TEST: Kill lvmetad early in teardown.
Message-ID: <20120926175530.8083BA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=376cb3fe64c4874fe4276722c4276521481dc80b
Commit:        376cb3fe64c4874fe4276722c4276521481dc80b
Parent:        17901569da5294322dcb09fd9b66531adabdf95d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 11 10:29:38 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 12:23:34 2012 +0200

TEST: Kill lvmetad early in teardown.

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 26508cf..0b46c79 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -164,6 +164,7 @@ teardown_devs() {
 
 teardown() {
 	echo -n "## teardown..."
+	test ! -s LOCAL_LVMETAD || kill -9 "$(cat LOCAL_LVMETAD)" || true
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
@@ -183,7 +184,6 @@ teardown() {
 
 	pgrep dmeventd || true
 	test ! -s LOCAL_DMEVENTD || kill -9 "$(cat LOCAL_DMEVENTD)" || true
-	test ! -s LOCAL_LVMETAD || kill -9 "$(cat LOCAL_LVMETAD)" || true
 
 	echo -n .
 


