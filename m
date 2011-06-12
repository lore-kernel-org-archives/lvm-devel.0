From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jun 2011 00:23:51 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c
Message-ID: <20110612002351.21003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-12 00:23:50

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 

Log message:
	Disable critical section internal errors until this can be fixed properly
	in libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2011&r2=1.2012
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2011/06/11 00:03:06	1.2011
+++ LVM2/WHATS_NEW	2011/06/12 00:23:50	1.2012
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Downgrade critical_section errors to debug level until it is moved to libdm.
   Fix ignored background polling default in vgchange -ay.
   Fix pvmove activation sequences to avoid trapped I/O with multiple LVs.
   Annotate critical section debug messages.
--- LVM2/lib/mm/memlock.c	2011/06/11 00:03:07	1.43
+++ LVM2/lib/mm/memlock.c	2011/06/12 00:23:50	1.44
@@ -405,8 +405,9 @@
 
 void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
+	/* FIXME Maintain accurate suspended device counter in libdevmapper */
 	if (!_critical_section_count)
-		log_error(INTERNAL_ERROR "_critical_section has dropped below 0.");
+		log_debug("_critical_section has dropped below 0.");
 	--_critical_section_count;
 	log_debug("critical_section_dec to %d (%s).", _critical_section_count,
 		  reason);


