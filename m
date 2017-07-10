From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:15 -0400
Subject: master - tests: fix tests variable
Message-ID: <201707101234.v6ACYF2M022921@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=270e526734ee6f97412adf52c52194c46ac9ae21
Commit:        270e526734ee6f97412adf52c52194c46ac9ae21
Parent:        38917ee51c4024e9562cba18bc4ed98188f6818c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 20:37:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix tests variable

Actually check $r instead or 'r' for test failure.
---
 test/shell/name-mangling.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 3e67587..3b699a2 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -197,8 +197,8 @@ ln -s "$DM_DEV_DIR/mapper/${PREFIX}abc" "$DM_DEV_DIR/${PREFIX}xyz"
 aux dmsetup status "$DM_DEV_DIR/${PREFIX}xyz" || r=1
 rm -f "$DM_DEV_DIR/${PREFIX}xyz"
 remove_dm_dev auto "abc"
-if [ r = 1 ]; then
-	exit 1
+if [ "$r" = 1 ]; then
+	return "$r"
 fi
 
 ### ALL WHITELISTED CHARACTERS ###


