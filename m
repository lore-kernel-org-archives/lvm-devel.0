From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Jan 2010 17:13:46 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100111171346.23132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-11 17:13:46

Modified files:
	tools          : lvconvert.c 

Log message:
	Found 2 problems with my previous check-in:
	
	date: 2010/01/07 20:42:55;  author: jbrassow;  state: Exp;  lines: +11 -0
	The patch fixes some lvconvert issues (WRT mirror <-> mirror).
	
	1) 'exisiting_mirrors' and 'lp->mirrors' where taken to be in 'n-1'
	notation (i.e a 2-way mirror is '1' and a linear is '0'), but the
	variables were in 'n' notation.
	2) After adding the redundant mirror log support, I was calculating
	log_count by looking at the mirror log LV, but didn't take into
	account the fact that there could be no mirror log!
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/tools/lvconvert.c	2010/01/08 22:32:35	1.106
+++ LVM2/tools/lvconvert.c	2010/01/11 17:13:45	1.107
@@ -668,10 +668,11 @@
 	 * the type of log wasn't specified, then let's keep the log type
 	 * the same.
 	 */
-	if (existing_mirrors && lp->mirrors &&
-	    (lp->mirrors != existing_mirrors) &&
+	if ((existing_mirrors > 1) && (lp->mirrors > 1) &&
+	    (lp->mirrors != existing_mirrors) && !(lv->status & CONVERTING) &&
 	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
-		log_count = lv_mirror_count(first_seg(lv)->log_lv);
+		log_count = (first_seg(lv)->log_lv) ?
+			lv_mirror_count(first_seg(lv)->log_lv) : 0;
 	}
 
 	if (repair) {


