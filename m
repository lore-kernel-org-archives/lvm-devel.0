From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:55 +0200
Subject: [PATCH 2/5] Remove vg_validate call when parsing cached metadata.
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <59763531708170fbd57e63cc407e7a7f7557c1b2.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vg_validate call is an adept to optimisation, it is very
ineeficient and slow.

Anyway, we should call it only before writing data to disk.

The call in lvmcache was just temporary validation,
we realy do not need to revalidate cached metadata
every time.
(Actually, I added that there just to prove that cache works
properly and forgot to remove it.)

Patch removes it from lvmcache completely, this can hit only
internal bug in export function (and this bug must
be detected in any vg_write call anyway before).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0ce034a..9caa216 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -610,8 +610,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
-	    !vg_validate(vg)) {
+	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
 		_free_cached_vgmetadata(vginfo);
 		vg_release(vg);
 		return_NULL;
-- 
1.7.0.3


