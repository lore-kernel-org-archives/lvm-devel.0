From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:06:53 +0000 (UTC)
Subject: master - metadata: Fix tracking of read_status flags in _vg_make_handle.
Message-ID: <20130722100653.31E9E60F93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d2604f02651158223ac31fe58e0638b6171171c
Commit:        6d2604f02651158223ac31fe58e0638b6171171c
Parent:        3ed7f78ff4d79831700806407c3728ea7d728488
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 12:04:47 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jul 22 12:04:47 2013 +0200

metadata: Fix tracking of read_status flags in _vg_make_handle.

---
 lib/metadata/metadata.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5624a5e..4ae7726 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -874,12 +874,12 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
-	if (vg->fid && !_vg_update_vg_ondisk(vg))
-		vg->read_status |= FAILED_ALLOCATION;
-
 	if (vg->read_status != failure)
 		vg->read_status = failure;
 
+	if (vg->fid && !_vg_update_vg_ondisk(vg))
+		vg->read_status |= FAILED_ALLOCATION;
+
 	return vg;
 }
 


