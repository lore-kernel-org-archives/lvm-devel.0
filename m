From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:06:03 +0000 (UTC)
Subject: master - cleanup: ensuring string is not NULL
Message-ID: <20151109160603.8880E60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45e749493c55ec349abfe9670cb46c6a70528ae4
Commit:        45e749493c55ec349abfe9670cb46c6a70528ae4
Parent:        76b42901c08bd66df600f3ad82fc2f179a3abc8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:58:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

cleanup: ensuring string is not NULL

Coverity cannot see the string cannot be NULL so make it explicit.
---
 lib/commands/toolcontext.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c150991..a2f21b8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -561,9 +561,9 @@ static int _process_config(struct cmd_context *cmd)
 #endif
 
 	dev_ext_info_src = find_config_tree_str(cmd, devices_external_device_info_source_CFG, NULL);
-	if (!strcmp(dev_ext_info_src, "none"))
+	if (dev_ext_info_src && !strcmp(dev_ext_info_src, "none"))
 		init_external_device_info_source(DEV_EXT_NONE);
-	else if (!strcmp(dev_ext_info_src, "udev"))
+	else if (dev_ext_info_src && !strcmp(dev_ext_info_src, "udev"))
 		init_external_device_info_source(DEV_EXT_UDEV);
 	else {
 		log_error("Invalid external device info source specification.");


