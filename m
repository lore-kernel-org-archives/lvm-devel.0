From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:26 +0000 (UTC)
Subject: master - lv_manip: preserve read-only status in layered volume
Message-ID: <20141024144026.6243460CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1cb267274916fcd63456a859ff433bdceefef07
Commit:        f1cb267274916fcd63456a859ff433bdceefef07
Parent:        be3f666ef3ad25f2af598ecfa305ab9c2f7de3f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 23 14:27:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

lv_manip: preserve read-only status in layered volume

---
 lib/metadata/lv_manip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3c84a5c..6240f14 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6075,7 +6075,9 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
+	if (!(layer_lv = lv_create_empty(name, NULL,
+					 /* Preserve read-only flag */
+					 LVM_READ | (lv_where->status & LVM_WRITE),
 					 ALLOC_INHERIT, lv_where->vg))) {
 		log_error("Creation of layer LV failed");
 		return NULL;


