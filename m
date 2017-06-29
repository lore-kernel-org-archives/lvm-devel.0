From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:58 -0400
Subject: master - tests: lvm-wrapper.sh double quote
Message-ID: <201706292028.v5TKSwxH026893@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1f80512c8965087fd77284078385afc689e845f
Commit:        b1f80512c8965087fd77284078385afc689e845f
Parent:        32be18959d7899822d80c715fd271410f05462f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:01:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: lvm-wrapper.sh double quote

---
 test/lib/lvm-wrapper.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 8a5323b..41fbec9 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -33,9 +33,9 @@ fi
 
 case "$CMD" in
   lvs|pvs|vgs|vgck|vgscan)
-	test ${LVM_DEBUG_LEVEL:-0} -lt 2 && RUN_DBG= ;;
+	test "${LVM_DEBUG_LEVEL:-0}" -lt 2 && RUN_DBG= ;;
   pvcreate|pvremove|lvremove|vgcreate|vgremove)
-	test ${LVM_DEBUG_LEVEL:-0} -lt 1 && RUN_DBG= ;;
+	test "${LVM_DEBUG_LEVEL:-0}" -lt 1 && RUN_DBG= ;;
 esac
 
 # Capture parallel users of debug.log file


