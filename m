From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 12:15:42 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20101129121542.27148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 12:15:42

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Use one fprintf call for usage print
	
	Replace multiple fprintf calls with multiline one.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/daemons/dmeventd/dmeventd.c	2010/11/29 11:23:14	1.70
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/11/29 12:15:41	1.71
@@ -1749,14 +1749,12 @@
 
 static void usage(char *prog, FILE *file)
 {
-	fprintf(file, "Usage:\n");
-	fprintf(file, "%s [-V] [-h] [-d] [-d] [-d] [-f]\n", prog);
-	fprintf(file, "\n");
-	fprintf(file, "   -V       Show version of dmeventd\n");
-	fprintf(file, "   -h       Show this help information\n");
-	fprintf(file, "   -d       Log debug messages to syslog (-d, -dd, -ddd)\n");
-	fprintf(file, "   -f       Don't fork, run in the foreground\n");
-	fprintf(file, "\n");
+	fprintf(file, "Usage:\n"
+		"%s [-V] [-h] [-d] [-d] [-d] [-f]\n\n"
+		"   -V       Show version of dmeventd\n"
+		"   -h       Show this help information\n"
+		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
+		"   -f       Don't fork, run in the foreground\n\n", prog);
 }
 
 int main(int argc, char *argv[])


