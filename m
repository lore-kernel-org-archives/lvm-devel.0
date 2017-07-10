From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:16 -0400
Subject: master - tests: drop unneeded echo
Message-ID: <201707101233.v6ACXGtY022746@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a5eea77581181ee9ddff0c4e3575bc3a73d2585
Commit:        4a5eea77581181ee9ddff0c4e3575bc3a73d2585
Parent:        2d96b758e4d127d144fdeb92b487cdc5f86de340
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:29:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop unneeded echo

---
 test/shell/thin-resize-match.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index b9bec9c..3bbf334 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -62,7 +62,7 @@ diff MD5  MD5-2
 
 
 # Do not want to see Live & Inactive table entry
-echo $(dm_info attr,name) | not grep "LI-.*${PREFIX}" || {
+( dm_info attr,name | not grep "LI-.*${PREFIX}" ) || {
         dmsetup table --inactive | grep ${PREFIX}
 	die "Found device with Inactive table"
 }


