From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 15:15:27 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090724151527.18100.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 15:15:26

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Eliminate compile warning introduced by previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.259&r2=1.260

--- LVM2/lib/metadata/metadata.c	2009/07/24 15:01:43	1.259
+++ LVM2/lib/metadata/metadata.c	2009/07/24 15:15:26	1.260
@@ -513,7 +513,6 @@
 {
 	int i;
 	struct physical_volume *pv;
-	struct cmd_context *cmd = vg->cmd;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;


