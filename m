From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:39 +0000 (UTC)
Subject: master - lv_manip: remove vg_revert
Message-ID: <20140910200539.BD55160DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f50cef96c651d155ff34b9b2fa7b73b673f528d0
Commit:        f50cef96c651d155ff34b9b2fa7b73b673f528d0
Parent:        c61c5f360d00097fcb97ac9d9dec6687cd86e35f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 8 22:39:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 21:57:38 2014 +0200

lv_manip: remove vg_revert

vg_commit is supposed to have implicit revert handling.
(however as of now it needs fixes).
---
 lib/metadata/lv_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3b158b8..2b00957 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6100,7 +6100,6 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 
 		if (!vg_commit(lv_where->vg)) {
 			log_error("Failed to commit intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
-			vg_revert(lv_where->vg);
 			return NULL;
 		}
 


