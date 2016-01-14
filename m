From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:27 +0000 (UTC)
Subject: master - cleanup: replace log_warn
Message-ID: <20160114103527.10E3760DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d2b7f2bd8c318ed65097d4cb7141b3035e43e2f
Commit:        7d2b7f2bd8c318ed65097d4cb7141b3035e43e2f
Parent:        2567d03e95bb4e46cd845c2ae8b518ec4989b939
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 8 11:08:07 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: replace log_warn

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6897801..99f3661 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4631,14 +4631,14 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
 			lp->stripes = lp->ac_stripes_value;
 		else
-			log_warn("Varied striping not supported. Ignoring.");
+			log_print_unless_silent("Varied striping not supported. Ignoring.");
 	}
 
 	if (lp->ac_mirrors) {
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
 			lp->mirrors = lp->ac_mirrors_value;
 		else
-			log_warn("Mirrors not supported. Ignoring.");
+			log_print_unless_silent("Mirrors not supported. Ignoring.");
 	}
 
 	if (lp->ac_stripesize && !_validate_stripesize(cmd, vg, lp))


