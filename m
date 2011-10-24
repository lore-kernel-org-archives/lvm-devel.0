From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Oct 2011 10:24:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20111024102440.13376.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-24 10:24:40

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Don't print char type[8] as a plain string
	
	pvck prints 'extra' character from the label since there is no '\0'
	after the struct label entry and just uint64_t follows directly.
	So avoid it by limiting 8 chars to be printed.
	
	https://www.redhat.com/archives/lvm-devel/2011-January/msg00109.html
	
	Signed-off-by: Paul Bolle <pebolle tiscali nl>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2170&r2=1.2171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.469&r2=1.470

--- LVM2/WHATS_NEW	2011/10/23 16:05:45	1.2170
+++ LVM2/WHATS_NEW	2011/10/24 10:24:39	1.2171
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Don't print char type[8] as a plain string in pvck PV type.
   Use vg memory pool implicitely for vg read.
   Always use vg memory pool for allocated lv segment.
   Remove extra 4kB buffer allocated on stack in print_log().
--- LVM2/lib/metadata/metadata.c	2011/10/11 09:09:00	1.469
+++ LVM2/lib/metadata/metadata.c	2011/10/24 10:24:40	1.470
@@ -3794,7 +3794,7 @@
 		return 0;
 	}
 
-	log_print("Found label on %s, sector %"PRIu64", type=%s",
+	log_print("Found label on %s, sector %"PRIu64", type=%.8s",
 		  pv_name, label->sector, label->type);
 
 	/*


