From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 19:50:26 +0000 (GMT)
Subject: main - tests: better reporting of problematic services
Message-ID: <20210326195026.7FE643857C7A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ef8d845694c79683ebdbdeec69eb2e534f4b1d2
Commit:        5ef8d845694c79683ebdbdeec69eb2e534f4b1d2
Parent:        49575a6ce1940528aaaac5eada8f8938e6cf4a84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:06:46 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:40 2021 +0100

tests: better reporting of problematic services

---
 test/shell/000-basic.sh | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index a7b80c72b..15f2a6021 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -38,11 +38,11 @@ not lvs "${DEVICES[@]}"
 # validate testing machine with its services is in expected state and will not interfere with tests
 if systemctl -a >out 2>/dev/null ; then
 	for i in dm-event lvm2-lvmpolld lvm2-monitor ; do
-	echo $i
-		grep $i out | not grep -v masked || {
-			cat out
-			should not echo "Present unmasked $i service/socket may randomize testing results!"
-			echo "+++++ Stop & Mask with systemctl +++++"
-		}
+		grep $i out > mout || continue
+		grep -v masked mout || continue
+		should not echo "Present unmasked $i service/socket may randomize testing results!"
+		echo "+++++ Stop & Mask with systemctl +++++"
+		touch show_out
 	done
+	test ! -e show_out || cat out
 fi


