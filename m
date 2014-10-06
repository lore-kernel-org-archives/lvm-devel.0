From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:25 +0000 (UTC)
Subject: master - lvconvert: splitsnapshot supports --yes
Message-ID: <20141006133325.C88C460DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb49dd4aa4e6fecb80c163f0279803d4036e48c5
Commit:        cb49dd4aa4e6fecb80c163f0279803d4036e48c5
Parent:        b2b18a5f8b4f6c5b116655f7e9e7c102462f693f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 14:42:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:22:22 2014 +0200

lvconvert: splitsnapshot supports --yes

Handle --yes arg to skip prompt.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6b768ea..d2b5303 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Support --yes with lvconvert --splitsnapshot.
   Fix detection of unsupported thin external lvconversions.
   Fix detection of unsupported cache and thin pool lvconversions.
   Fix detection of unsupported lvconversion of cache to snapshot.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 070c5e4..4bf4306 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2002,7 +2002,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		if (!lv_check_not_in_use(cow))
 			return_ECMD_FAILED;
 
-		if ((lp->force == PROMPT) &&
+		if ((lp->force == PROMPT) && !lp->yes &&
 		    lv_is_visible(cow) &&
 		    lv_is_active(cow)) {
 			if (yes_no_prompt("Do you really want to split off active "


