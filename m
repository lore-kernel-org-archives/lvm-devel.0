From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:47:48 -0000
Subject: LVM2/lib/metadata metadata-exported.h
Message-ID: <20100521124748.18423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:47:47

Modified files:
	lib/metadata   : metadata-exported.h 

Log message:
	Replicator: extend volume_group with list of VGs and flag
	
	Add pointer to linked list of opened VGs. List temporarily keeps
	the information about needed or locked and opened VGs for replicator target.
	
	Also add cmd_missing_vgs flag information for quick check and
	also for possible continuos process_each_lv() usage where we need
	to detect whether failure has been caused by missing VG or
	some other reason.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:36:31	1.147
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/21 12:47:46	1.148
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -223,6 +223,8 @@
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
+	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
 
 	alloc_policy_t alloc;


