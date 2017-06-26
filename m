From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:28 -0400
Subject: master - dev_manager: add missing validation for usable target_name
Message-ID: <201706262229.v5QMTS14010115@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab6f4649a0d533b84a7496d88acefa318212d162
Commit:        ab6f4649a0d533b84a7496d88acefa318212d162
Parent:        b1e21cf9ed585796cd2d265c3bda50b7960b0478
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:34:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:25 2017 +0200

dev_manager: add missing validation for usable target_name

Coverity shown path where target_name == NULL would be dereferenced.
---
 lib/activate/dev_manager.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d10a917..daddfc8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -275,7 +275,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 			target_params = NULL; /* Marking this target_params unusable */
 		} while (target);
 
-		if (!_get_segment_status_from_target_params(target_name, target_params, seg_status))
+		if (!target_name ||
+		    !_get_segment_status_from_target_params(target_name, target_params, seg_status))
 			stack;
 	}
 


