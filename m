From: David Teigland <teigland@sourceware.org>
Date: Fri,  4 Sep 2020 16:23:40 +0000 (GMT)
Subject: master - tests: fix pvck repair in hints.sh
Message-ID: <20200904162340.A3E043857833@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dddf63ebc397705dc04a548c7a80ad9cad5ce4c2
Commit:        dddf63ebc397705dc04a548c7a80ad9cad5ce4c2
Parent:        10fc3610c46be494c6d15c845b2b85a3ca955d79
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 11:22:42 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 11:23:25 2020 -0500

tests: fix pvck repair in hints.sh

---
 test/shell/hints.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 176ee2176..5ac72282b 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -345,7 +345,7 @@ not diff $HINTS $PREV
 rm $HINTS $PREV
 pvs
 cp $HINTS $PREV
-pvck --repairtype label_header -y "$dev5"
+pvck --repairtype label_header -y "$dev3"
 cat $NEWHINTS
 grep 'Created empty by pvck' $HINTS
 # this next pvs creates new hints


