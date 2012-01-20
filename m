From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 10:59:27 -0000
Subject: LVM2/daemons/dmeventd/plugins/thin dmeventd_thin.c
Message-ID: <20120120105927.2485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 10:59:26

Modified files:
	daemons/dmeventd/plugins/thin: dmeventd_thin.c 

Log message:
	Thin forgotten initialisation of pointer to NULL
	
	Since the code may go in error path, set to defined NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2012/01/19 15:21:23	1.3
+++ LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2012/01/20 10:59:26	1.4
@@ -142,7 +142,7 @@
 	const char *device = dm_task_get_name(dmt);
 	int percent;
 	struct dso_state *state = *private;
-	struct dm_status_thin_pool *tps;
+	struct dm_status_thin_pool *tps = NULL;
 	void *next = NULL;
 	uint64_t start, length;
 	char *target_type = NULL;


