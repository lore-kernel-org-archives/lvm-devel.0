From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:25 +0000 (UTC)
Subject: dev-mornfall-lvmcache - fid: fix reset of PV fid
Message-ID: <20130605120425.39E9460DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f1a571c9707d596d7716cec9488e54ba4c0c946
Commit:        2f1a571c9707d596d7716cec9488e54ba4c0c946
Parent:        55f42944bd76ffdf3f77331c491e7de24ed56a2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:42:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 16:52:39 2013 +0200

fid: fix reset of PV fid

Avoid hitting memory corruption (double free) in code path,
where PV FID has been already destroyed and the released pointer
was left in PV structure and could have been tried to be released
from there 2nd. time with final context destruction.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 40fd569..f5adc0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix release of PV's fid in free_pv_fid().
   Skip monitoring of snapshots that are already bigger then origin.
   Add lv_is_cow_covering_origin() to check if cow covers origin size.
   Use libdm dm_get_status_snapshot() to parse snapshot status.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 351d157..62b5c3f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3402,8 +3402,7 @@ void free_pv_fid(struct physical_volume *pv)
 	if (!pv)
 		return;
 
-	if (pv->fid)
-		pv->fid->fmt->ops->destroy_instance(pv->fid);
+	pv_set_fid(pv, NULL);
 }
 
 /* This is only called by lv_from_lvid, which is only called from


