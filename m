From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:41 +0000 (UTC)
Subject: master - cleanup: use return_NULL
Message-ID: <20120823124241.3C913A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14d2b5a13ff6637f2ff1e8bd40dc8ca67e53e51b
Commit:        14d2b5a13ff6637f2ff1e8bd40dc8ca67e53e51b
Parent:        c8ad1f3e3a280b8cf3ca219dd6a6f3313b8be8d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 12:04:52 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:38 2012 +0200

cleanup: use return_NULL

Function returns pointer, so use NULL.
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index bb949b5..db092ac 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -189,7 +189,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	if (vgid) {
 		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
-			return_0;
+			return_NULL;
 		reply = daemon_send_simple(_lvmetad, "vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)


