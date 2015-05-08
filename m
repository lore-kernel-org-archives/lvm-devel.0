From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:50 +0000 (UTC)
Subject: master - debug: tracing error path
Message-ID: <20150508131650.E52A960E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29c709f5914ccd9159d84f8920c34b2c6ef51740
Commit:        29c709f5914ccd9159d84f8920c34b2c6ef51740
Parent:        eadebc3b615c8dec8f99f5e411b01c97b791987b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 12:37:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

debug: tracing error path

---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index a0418ce..ff8b657 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1904,7 +1904,7 @@ static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 	}
 
 	if (!_create_mimage_lvs(ah, mirrors, stripes, stripe_size, lv, img_lvs, log))
-		return 0;
+		return_0;
 
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
 			       MIRROR_IMAGE | (lv->status & LOCKED),


