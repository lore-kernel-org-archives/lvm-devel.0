From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:22 +0000 (UTC)
Subject: master - tests: fix test warning
Message-ID: <20150402114122.D073F6023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee65528547aaec2076d7dc5bf61285732dbbb534
Commit:        ee65528547aaec2076d7dc5bf61285732dbbb534
Parent:        536f5fa0a310fe863340768ea1a8b062b63e02ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 12:37:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: fix test warning

We cannot print TEST WARNING within test shell script
(since it's running in debug mode and thus always prints it)

Use 'should false' trick let the string printed in this case.
So 'non cluster cases' should now end properly.
---
 test/shell/pvmove-all-segtypes.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 457054b..ce95059 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -58,7 +58,7 @@ lvremove -ff $vg
 
 if test -e LOCAL_CLVMD ; then
 #FIXME these tests currently fail end require cmirrord
-echo "TEST WARNING, FIXME!!! pvmove in clustered VG not fully supported!"
+echo "$(should false)FIXME!!! pvmove in clustered VG not fully supported!"
 else
 
 # Testing pvmove of mirror LV


