From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:41 +0000 (GMT)
Subject: main - metadata: avoid excessive check of /etc/localtime
Message-ID: <20210927165741.ECACB3858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a3aabb8326c3ccfb9266663b538b9769ebccf28
Commit:        3a3aabb8326c3ccfb9266663b538b9769ebccf28
Parent:        61a6f9905e87e650f0bddae83fec6923bb100a57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 15:52:41 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:13 2021 +0200

metadata: avoid excessive check of /etc/localtime

With larger metadata, decoding 'localtime()' for hinting time creation
of every LV may cause excessive check of /etc/localtime file.
Set TZ to ":/etc/localtime" so glibc reads this file just once
instead of check everytime if there has anything changed.
---
 tools/lvmcmdline.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7c5930006..1fc2dc3bb 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3043,6 +3043,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int skip_hyphens;
 	int refresh_done = 0;
 
+	/* Avoid excessive access to /etc/localtime and set TZ variable for glibc
+	 * so it does not need to check /etc/localtime everytime that needs that info */
+	if (!getenv("TZ"))
+		setenv("TZ", ":/etc/localtime", 0);
+
 	init_error_message_produced(0);
 
 	/* each command should start out with sigint flag cleared */


