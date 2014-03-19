From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:14 +0000 (UTC)
Subject: master - cleanup: simplify pv name print
Message-ID: <20140319000214.ABA1360FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caf93eb1cb74050658dcf1816254ae3666aa3818
Commit:        caf93eb1cb74050658dcf1816254ae3666aa3818
Parent:        506091be70b3ebaed02c5d9c1c8fa991f4382182
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:01:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:58:01 2014 +0100

cleanup: simplify pv name print

pv_vg_name() now already hides orphans.
---
 lib/metadata/metadata.c |    2 +-
 lib/metadata/pv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff14e16..c79f223 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1408,7 +1408,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		log_warn("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? pv_vg_name(pv) : "",
+			  pv_vg_name(pv),
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index cb19be2..3613515 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -716,7 +716,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 		log_warn("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? pv_vg_name(pv) : "",
+			  pv_vg_name(pv),
 			  !is_orphan(pv) ? "\"" : "");
 	}
 


