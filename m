From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 5 Feb 2008 09:38:05 -0000
Subject: LVM2 ./WHATS_NEW man/clvmd.8 daemons/clvmd/clvmd.c
Message-ID: <20080205093805.12399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2008-02-05 09:38:04

Modified files:
	.              : WHATS_NEW 
	man            : clvmd.8 
	daemons/clvmd  : clvmd.c 

Log message:
	Update usage message for clvmd.
	Fix clvmd man page printing <br>, clarified debug options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.787&r2=1.788
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2008/01/31 12:41:13	1.787
+++ LVM2/WHATS_NEW	2008/02/05 09:38:04	1.788
@@ -1,5 +1,7 @@
 Version 2.02.34 -
 ===================================
+  Update usage message for clvmd.
+  Fix clvmd man page printing <br>, clarified debug options.
 
 Version 2.02.33 - 31st January 2008
 ===================================
--- LVM2/man/clvmd.8	2007/08/17 11:51:23	1.5
+++ LVM2/man/clvmd.8	2008/02/05 09:38:04	1.6
@@ -35,6 +35,16 @@
 Without this switch, only the local clvmd will change its debug level to that
 given with 
 .B -d.
+.br
+This does not work correctly if specified on the command-line that starts clvmd.
+If you want to start clvmd 
+.B and 
+enable cluster-wide logging then the command needs to be issued twice, eg:
+.br
+clvmd
+.br
+clvmd -d2
+.br
 .TP
 .I \-t <timeout>
 Specifies the timeout for commands to run around the cluster. This should not
@@ -52,11 +62,11 @@
 return code of 5 it is usually not necessary to restart clvmd - it will start
 as soon as that blockage has cleared. This flag is to allow startup scripts
 to exit in a timely fashion even if the cluster is stalled for some reason.
-<br>
+.br
 The default is 0 (no timeout) and the value is in seconds. Don't set this too
 small or you will experience spurious errors. 10 or 20 seconds might be
 sensible.
-<br>
+.br
 This timeout will be ignored if you start clvmd with the -d switch.
 .TP
 .I \-R
--- LVM2/daemons/clvmd/clvmd.c	2007/11/15 10:16:14	1.40
+++ LVM2/daemons/clvmd/clvmd.c	2008/02/05 09:38:04	1.41
@@ -146,8 +146,10 @@
 	fprintf(file, "\n");
 	fprintf(file, "   -V       Show version of clvmd\n");
 	fprintf(file, "   -h       Show this help information\n");
-	fprintf(file, "   -d       Don't fork, run in the foreground\n");
+	fprintf(file, "   -d       Set debug level\n");
+	fprintf(file, "            If starting clvmd then don't fork, run in the foreground\n");
 	fprintf(file, "   -R       Tell all running clvmds in the cluster to reload their device cache\n");
+	fprintf(file, "   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n");
 	fprintf(file, "   -t<secs> Command timeout (default 60 seconds)\n");
 	fprintf(file, "   -T<secs> Startup timeout (default none)\n");
 	fprintf(file, "\n");


