From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:34 +0000 (UTC)
Subject: master - test: Allow a longer timeout for lvextend-snapshot-dmeventd.
Message-ID: <20150205134334.1014960EAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72ee3f920b235c516328e92757571d311308f439
Commit:        72ee3f920b235c516328e92757571d311308f439
Parent:        839ea48aa97a541638cf7f2ac6ea48695116c014
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 09:52:09 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Allow a longer timeout for lvextend-snapshot-dmeventd.

---
 test/shell/lvextend-snapshot-dmeventd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 3d9ce1f..448df96 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -26,7 +26,7 @@ percent_() {
 
 wait_for_change_() {
 	# dmeventd only checks every 10 seconds :(
-	for i in $(seq 1 15) ; do
+	for i in $(seq 1 25) ; do
 		test "$(percent_)" != "$1" && return
 		sleep 1
 	done


