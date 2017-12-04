From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:09 -0500
Subject: master - cleanup: use existing define with prefix
Message-ID: <201712041458.vB4Ew9Ed007200@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=110dac870c0a0f53b4569f99daf5b6ac83a549f0
Commit:        110dac870c0a0f53b4569f99daf5b6ac83a549f0
Parent:        1f73cadd2d7cf7eaef2bc9c9944b2c72fb67bf2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 14:26:37 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: use existing define with prefix

---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1985c30..1d21443 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -566,7 +566,7 @@ static int _process_config(struct cmd_context *cmd)
 #ifdef DEVMAPPER_SUPPORT
 	dm_set_dev_dir(cmd->dev_dir);
 
-	if (!dm_set_uuid_prefix("LVM-"))
+	if (!dm_set_uuid_prefix(UUID_PREFIX))
 		return_0;
 #endif
 


