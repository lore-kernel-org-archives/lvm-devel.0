From: Milan Broz <mbroz@redhat.com>
Date: Mon, 15 Mar 2010 20:17:05 +0100
Subject: [PATCH] Disable long living process flag in lvm2app.
Message-ID: <1268680625-25853-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This option should be configurable, but for now
do not set it at all.

(lvm2app is used in udisks probers and there
cac cause several nasty races when trying to update
lvmcache during rescan.)
---
 liblvm/lvm_base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index ac94692..da07e81 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -32,7 +32,7 @@ lvm_t lvm_init(const char *system_dir)
 
 	/* create context */
 	/* FIXME: split create_toolcontext */
-	cmd = create_toolcontext(1, system_dir);
+	cmd = create_toolcontext(0, system_dir);
 	if (!cmd)
 		return NULL;
 
-- 
1.7.0


