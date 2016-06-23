From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:10:51 +0000 (UTC)
Subject: master - cleanup: clean warns from older gcc
Message-ID: <20160623231051.72B1B6112A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e88e9ee9eda8981cccb03d053189d05718891d53
Commit:        e88e9ee9eda8981cccb03d053189d05718891d53
Parent:        5070e7fcf79a3bcb21982d219c6f8dd484e523ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 01:10:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 01:10:04 2016 +0200

cleanup: clean warns from older gcc

Don't report uninitialized use by older gcc.
---
 lib/cache/lvmetad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index ee44202..a0a17ac 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1484,8 +1484,8 @@ int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct devi
 	daemon_reply reply;
 	struct lvmcache_info *info;
 	struct dm_config_tree *pvmeta, *vgmeta;
-	const char *status, *vgname;
-	int64_t changed;
+	const char *status = NULL, *vgname = NULL;
+	int64_t changed = 0;
 	int result;
 
 	if (!lvmetad_used() || test_mode())


