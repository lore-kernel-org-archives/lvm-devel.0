From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:53:02 +0000 (UTC)
Subject: master - TEST: Give lvmetad a chance to exit gracefully upon teardown.
Message-ID: <20121009055302.0383E241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=556d2c920aacb857377c6cfdb0fa3f6c50f6721b
Commit:        556d2c920aacb857377c6cfdb0fa3f6c50f6721b
Parent:        39468b73a33853c2e532375762a2bbf1e76ea406
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:25:51 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

TEST: Give lvmetad a chance to exit gracefully upon teardown.

---
 test/lib/aux.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 37e7f69..107afc1 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -167,7 +167,9 @@ teardown_devs() {
 
 teardown() {
 	echo -n "## teardown..."
-	test ! -s LOCAL_LVMETAD || kill -9 "$(cat LOCAL_LVMETAD)" || true
+	test ! -s LOCAL_LVMETAD || \
+	    (kill -TERM "$(cat LOCAL_LVMETAD)" && sleep 1 &&
+	     kill -KILL "$(cat LOCAL_LVMETAD)" 2> /dev/null) || true
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid


