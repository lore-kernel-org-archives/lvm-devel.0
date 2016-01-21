From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 11:12:18 +0000 (UTC)
Subject: master - cleanup: join if/else
Message-ID: <20160121111218.DFC3660FAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc53a23d8238abfe18441ed9000b75bbc8512d6e
Commit:        cc53a23d8238abfe18441ed9000b75bbc8512d6e
Parent:        3e09f916b4d4b4e93372305f90f5f22ce227c51a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 10:16:16 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 12:11:37 2016 +0100

cleanup: join if/else

---
 lib/metadata/lv_manip.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b67a2b7..9240de4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4867,10 +4867,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		if (!lp->ac_mirrors && seg_mirrors) {
 			log_print_unless_silent("Extending %" PRIu32 " mirror images.", seg_mirrors);
 			lp->mirrors = seg_mirrors;
-		}
-
-		if ((lp->ac_mirrors || seg_mirrors) &&
-		    (lp->mirrors != seg_mirrors)) {
+		} else if ((lp->ac_mirrors || seg_mirrors) && (lp->mirrors != seg_mirrors)) {
 			log_error("Cannot vary number of mirrors in LV yet.");
 			return 0;
 		}


