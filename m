From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Jan 2016 13:20:44 +0000 (UTC)
Subject: master - lvmcache: invalidate all cached dev sizes if all VGs got unlocked
Message-ID: <20160122132044.C562C60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f5dfb7369600c169ecd2c78e0cd079ad1442548
Commit:        1f5dfb7369600c169ecd2c78e0cd079ad1442548
Parent:        d090d6574e455625ad4e2a1a6f3d93f5c663b097
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 22 11:13:00 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 22 14:16:00 2016 +0100

lvmcache: invalidate all cached dev sizes if all VGs got unlocked

---
 lib/cache/lvmcache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2864ffb..4a4b53f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -452,8 +452,10 @@ void lvmcache_unlock_vgname(const char *vgname)
 	dm_hash_remove(_lock_hash, vgname);
 
 	/* FIXME Do this per-VG */
-	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked)
+	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked) {
 		dev_close_all();
+		dev_size_seqno_inc(); /* invalidate all cached dev sizes */
+	}
 }
 
 int lvmcache_vgs_locked(void)


