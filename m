From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jan 2017 14:56:41 +0000 (UTC)
Subject: master - report: report merged state for inactive LV
Message-ID: <20170105145641.F3ACB60E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74969c9a38c286037d499a6ed603b1ae806cd37b
Commit:        74969c9a38c286037d499a6ed603b1ae806cd37b
Parent:        d6a74025df1afb3d76bec435bc6a40d649217b42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 5 15:52:00 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 5 15:54:14 2017 +0100

report: report merged state for inactive LV

This was missing piece in 77997c7673bfca56f51ae4eb55a50bc76e40fe79.
When merging origin is inactive (while driver is loaded) we
could already report merge in progress values as there is
no way to activate 'old state' now.
---
 tools/reporter.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 6c5996b..e70fa29 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -136,11 +136,14 @@ static int _check_merging_origin(const struct logical_volume *lv,
 	case SEG_STATUS_SNAPSHOT:
 		break;
 	default:
+		/* When inactive, it's technically merging */
+		if (status->info_ok && !status->info.exists)
+			break;
 		return 1;
 	}
 
 	/* Origin is gone */
-	log_debug_activation("Merge is progress, reporting merged LV %s.",
+	log_debug_activation("Merge is in progress, reporting merged LV %s.",
 			     display_lvname(lv->snapshot->lv));
 	*merged = 1;
 


