From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Dec 2009 15:59:54 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091217155954.4044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-17 15:59:54

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Revert another unintended change that snuck in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/lib/metadata/mirror.c	2009/12/17 15:38:29	1.100
+++ LVM2/lib/metadata/mirror.c	2009/12/17 15:59:53	1.101
@@ -784,7 +784,7 @@
 					 DEFAULT_MIRROR_LOG_FAULT_POLICY);
 	else
 		policy = find_config_str(NULL, "activation/mirror_device_fault_policy",
-					 DEFAULT_MIRROR_IMAGE_FAULT_POLICY);
+					 DEFAULT_MIRROR_DEV_FAULT_POLICY);
 
 	if (!strcmp(policy, "remove"))
 		return MIRROR_REMOVE;


