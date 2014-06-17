From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:35 +0000 (UTC)
Subject: master - snapshot: report proper error message
Message-ID: <20140617132435.AD54861207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd6d6fc24e8093d437543613ddbcbdb0e9c5f8c8
Commit:        cd6d6fc24e8093d437543613ddbcbdb0e9c5f8c8
Parent:        15e7066fe3ea7ca9129b68e3b39e9667348a02cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 17 13:13:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:36:33 2014 +0200

snapshot: report proper error message

Expresing -lXX%LV is not valid for snapshot, but error message for
snapshost case was not complete and missed %ORIGIN.
Also document correct settings for in manpage properly where
it missed %PVS.
---
 man/lvcreate.8.in |    2 +-
 tools/lvcreate.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 9892c21..9301063 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -90,7 +90,7 @@ lvcreate \- create a logical volume in an existing volume group
 
 .B lvcreate
 .RB [ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { VG | FREE | ORIGIN }]
+.IR LogicalExtentsNumber [ % { ORIGIN | VG | PVS | FREE }]
 |
 .BR \-L | \-\-size
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2156265..1fa5aef 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -380,8 +380,8 @@ static int _update_extents_params(struct volume_group *vg,
 				extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_LV:
-			log_error("Please express size as %%VG, %%PVS, or "
-				  "%%FREE.");
+			log_error("Please express size as %s%%VG, %%PVS, "
+				  "or %%FREE.", (lp->snapshot) ? "%ORIGIN, " : "");
 			return 0;
 		case PERCENT_ORIGIN:
 			if (lp->snapshot && lp->origin &&


