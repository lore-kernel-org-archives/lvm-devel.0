From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:25 -0400
Subject: master - tests: use read -r
Message-ID: <201707101233.v6ACXPvB022818@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74ef5f07d0940a1ce784d569ce7d0bbeef74db87
Commit:        74ef5f07d0940a1ce784d569ce7d0bbeef74db87
Parent:        7a8f87d28b3ccd3fc4890606c3edf83896d6624e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 10:39:18 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: use read -r

---
 test/shell/clvmd-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index e3c9d5f..7e3257a 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 # only clvmd based test, skip otherwise
-read LOCAL_CLVMD < LOCAL_CLVMD
+read -r LOCAL_CLVMD < LOCAL_CLVMD
 
 # TODO read from build, for now hardcoded
 CLVMD_SOCKET="/var/run/lvm/clvmd.sock"


