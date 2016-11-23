From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:45 +0000 (UTC)
Subject: master - mirror: preserve MIRRORED status for temporara image
Message-ID: <20161123165545.D8A8F60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ad95b77d0f3eb38bc678bf15ecb899e109287cc
Commit:        0ad95b77d0f3eb38bc678bf15ecb899e109287cc
Parent:        851095a6af7a5a1343d9eb2aa8a5c9e08f9759b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 17:11:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:47:58 2016 +0100

mirror: preserve MIRRORED status for temporara image

When lvconvert adds a new leg - it's doing it free 'temporary' image
layer - however this temporary 'internal' mirror is also MIRRORED LV.
But the status bit was not properly transfered through layer.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b7a5e82..40a9ef4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Preserve mirrored status for temporary layered mirrors.
   Use transient raid check before repairing raid volume.
   Implement transient status check for raid volumes.
   Only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index da7be6c..feb78a5 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1883,7 +1883,9 @@ static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 		return_0;
 
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
-			       MIRROR_IMAGE | (lv->status & LOCKED),
+			       /* Pass through MIRRORED & LOCKED status flag
+				* TODO: Any other would be needed ?? */
+			       MIRROR_IMAGE | (lv->status & (MIRRORED | LOCKED)),
 			       region_size)) {
 		log_error("Aborting. Failed to add mirror segment. "
 			  "Remove new LV and retry.");


