From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Sep 2015 18:11:46 +0000 (UTC)
Subject: master - lockd: fix rescanning VG metadata
Message-ID: <20150911181146.45C9461141@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a26c20b88ab5fe7894a2e2207fd492aaca41095
Commit:        0a26c20b88ab5fe7894a2e2207fd492aaca41095
Parent:        0889cff5d5430cc398586285be5cccd88b4ed18f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 11 13:08:59 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 11 13:10:48 2015 -0500

lockd: fix rescanning VG metadata

The code was expecting the wrong return value from
compare_config, which returns 0 when equal.

This is a problem for a lockd VG using multiple PVs
when the VG needs to be rescanned.
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b2e2f55..0fff65a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1174,7 +1174,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		if (!vgmeta_ret) {
 			vgmeta_ret = vgmeta;
 		} else {
-			if (!compare_config(vgmeta_ret->root, vgmeta->root)) {
+			if (compare_config(vgmeta_ret->root, vgmeta->root)) {
 				log_error("VG metadata comparison failed");
 				dm_config_destroy(vgmeta);
 				dm_config_destroy(vgmeta_ret);


