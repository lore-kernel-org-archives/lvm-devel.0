From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Jan 2011 14:56:27 -0600
Subject: [PATCH 1 of 4] LVM: cleanup 1
Message-ID: <201101102056.p0AKuRxu011888@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-cleanup-1.patch

lvcreate() does a 'memset(&lp, 0, sizeof(lp))', which is done by very
next function called.  No need to do it twice.

Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -538,8 +538,6 @@ int lvcreate(struct cmd_context *cmd, in
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
 
-	memset(&lp, 0, sizeof(lp));
-
 	if (!_lvcreate_params(&lp, &lcp, cmd, argc, argv))
 		return EINVALID_CMD_LINE;
 


