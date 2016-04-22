From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 12:16:25 +0000 (UTC)
Subject: master - tests: drop cluster testing with pvmove
Message-ID: <20160422121625.18D756207B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31b11d02281a3d141fa2c69d9155baacd158bf50
Commit:        31b11d02281a3d141fa2c69d9155baacd158bf50
Parent:        a88828c8455823da52f6dbb0b5c77e2cc8b550e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 14:08:31 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 14:15:36 2016 +0200

tests: drop cluster testing with pvmove

Unwanteadly enabled in previous check-in.
---
 test/shell/pvmove-resume-multiseg.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index b06400c..c22770f 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -15,7 +15,7 @@
 # Multisegment variant w/ 2 pvmoves LVs per VG
 
 SKIP_WITH_LVMLOCKD=1
-#SKIP_WITH_CLVMD=1
+SKIP_WITH_CLVMD=1
 
 . lib/inittest
 


