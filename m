From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:15:03 -0500
Subject: stable-2.02 - lvmcache: free resource on error path
Message-ID: <201911081415.xA8EF3gj008335@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34bde8b6c7e517239a05334683a09f2b5075fdcc
Commit:        34bde8b6c7e517239a05334683a09f2b5075fdcc
Parent:        f90c3d69cedf94fa094bc71cc98376d58d970223
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 12:51:48 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 15:11:50 2019 +0100

lvmcache: free resource on error path

Free allocated svg on error path.
Also explicitely ignore dm_strncpy() result.
(We know it will end with failure here.)
---
 lib/cache/lvmcache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9890325..c12ec2b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -325,10 +325,12 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 
 		dm_list_init(&svg->saved_vg_to_free);
 
-		dm_strncpy(svg->vgid, (const char *)vg->id.uuid, sizeof(svg->vgid));
+		/* Ignore result code, size we intentionally short-cut & pad with 0 */
+		(void) dm_strncpy(svg->vgid, (const char *)vg->id.uuid, sizeof(svg->vgid));
 
 		if (!dm_hash_insert(_saved_vg_hash, svg->vgid, svg)) {
 			log_error("lvmcache: failed to insert saved_vg %s", svg->vgid);
+			dm_free(svg);
 			return;
 		}
 	} else {


