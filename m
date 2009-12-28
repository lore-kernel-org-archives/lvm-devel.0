From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 20:09:09 +0100
Subject: [PATCH] Do not set precommitted flag in cache when precommitted metadata does not exist.
Message-ID: <1262027349-19048-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The use_precommited flag indicates that we want to use precommited metadata
(used in suspend call to preload table with precommitted data).

But if there are no such data, committed metadata are read, but the cache
still contains precommitted flag.

(The problem is that later possible drop_metadata call will not invalidate
device in cache.)

The wrong precomitted state is stored on remote nodes during normal
suspend/resume cycle _without_ involving vg_write/commit.

Use the PRECOMMITED VG status flag here instead (which is always set if using
precommited metadata here).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f2ff8ac..c24bbda 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2620,7 +2620,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (!inconsistent_pvs) {
 				log_debug("Updating cache for PVs without mdas "
 					  "in VG %s.", vgname);
-				lvmcache_update_vg(correct_vg, use_precommitted);
+				lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
 				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
 					return_NULL;
@@ -2721,7 +2721,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return_NULL;
 	}
 
-	lvmcache_update_vg(correct_vg, use_precommitted);
+	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
-- 
1.6.5.7


