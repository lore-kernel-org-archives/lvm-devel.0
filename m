From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2008 17:51:04 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20080603175104.16348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-03 17:51:04

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Correct config file line numbers in messages when parsing comments. (kabi)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.878&r2=1.879
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2008/05/30 15:27:44	1.878
+++ LVM2/WHATS_NEW	2008/06/03 17:51:03	1.879
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Correct config file line numbers in messages when parsing comments.
   In script-processing mode, stop if any command fails.
   Warn if command exits with non-zero status code without a prior log_error.
   Make clvmd-cman use a hash rather than an array for node updown info.
--- LVM2/lib/config/config.c	2008/03/12 16:03:21	1.68
+++ LVM2/lib/config/config.c	2008/06/03 17:51:04	1.69
@@ -798,11 +798,9 @@
 static void _eat_space(struct parser *p)
 {
 	while ((p->tb != p->fe) && (*p->tb)) {
-		if (*p->te == '#') {
+		if (*p->te == '#')
 			while ((p->te != p->fe) && (*p->te) && (*p->te != '\n'))
 				p->te++;
-			p->line++;
-		}
 
 		else if (isspace(*p->te)) {
 			while ((p->te != p->fe) && (*p->te) && isspace(*p->te)) {


