From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:21:25 -0600
Subject: [PATCH 1 of 10] LVM: remove prevention checks for mirrored log
Message-ID: <201001200221.o0K2LPmg023820@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-remove-prevention-checks-for-mirrored-log.patch

In preparation for redundant (mirrored) mirror logs, remove the
checks that prevent this sort of processing.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1563,11 +1563,6 @@ static struct logical_volume *_set_up_mi
 
 	init_mirror_in_sync(in_sync);
 
-	if (log_count != 1) {
-		log_error("log_count != 1 is not supported.");
-		return NULL;
-	}
-
 	/* Mirror log name is lv_name + suffix, determined as the following:
 	 *   1. suffix is:
 	 *        o "_mlog" for the original mirror LV.
@@ -1630,12 +1625,6 @@ int add_mirror_log(struct cmd_context *c
 	struct lvinfo info;
 	int r = 0;
 
-	/* Unimplemented features */
-	if (log_count > 1) {
-		log_error("log_count > 1 is not supported");
-		return 0;
-	}
-
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;


