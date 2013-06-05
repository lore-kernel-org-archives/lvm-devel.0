From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:20 +0000 (UTC)
Subject: dev-mornfall-lvmcache - vg_validate: A little more detailed diagnostic.
Message-ID: <20130605120620.5869461057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e83984dca5d477e5ddab7bcaea542b84ffc8fc2a
Commit:        e83984dca5d477e5ddab7bcaea542b84ffc8fc2a
Parent:        f4d8d73ad316fceafd8246e0cf50af0b802da16f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 14:55:25 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:37 2013 +0200

vg_validate: A little more detailed diagnostic.

---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e5bce1b..fcb2fa8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2301,8 +2301,8 @@ int vg_validate(struct volume_group *vg)
 		}
 
 		if (pvl->pv->vg != vg) {
-			log_error(INTERNAL_ERROR "VG %s PV list entry points "
-				  "to different VG %s.", vg->name,
+			log_error(INTERNAL_ERROR "VG %s PV %s list entry points "
+				  "to different VG %s.", vg->name, dev_name(pvl->pv->dev),
 				  pvl->pv->vg ? pvl->pv->vg->name : "NULL");
 			r = 0;
 		}


