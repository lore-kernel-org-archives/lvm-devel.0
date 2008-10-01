From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Oct 2008 22:48:27 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20081001224827.22634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-01 22:48:27

Modified files:
	.              : WHATS_NEW 

Log message:
	device->devices

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.969&r2=1.970

--- LVM2/WHATS_NEW	2008/09/30 20:37:52	1.969
+++ LVM2/WHATS_NEW	2008/10/01 22:48:26	1.970
@@ -16,7 +16,7 @@
   No longer write out PARTIAL flag into metadata backups.
   Treat new default activation/missing_stripe_filler "error" as an error target.
   Remove internal partial_mode.
-  Add device/md_chunk_alignment to lvm.conf.
+  Add devices/md_chunk_alignment to lvm.conf.
   Pass struct physical_volume to pe_align and adjust for md chunk size.
   Store sysfs location in struct cmd_context.
   Avoid shuffling remaining mirror images when removing one, retaining primary.


