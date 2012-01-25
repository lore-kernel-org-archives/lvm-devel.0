From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:20:12 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c tools/lvmdi ...
Message-ID: <20120125222012.8741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:20:11

Modified files:
	daemons/clvmd  : clvmd-command.c 
	tools          : lvmdiskscan.c 

Log message:
	Set to a defined value vars used after error path
	
	Static analyzer noticed this vars are used even when error is reported
	back thus their state is undefined - set to 0 for this case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/daemons/clvmd/clvmd-command.c	2012/01/25 22:17:57	1.63
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/01/25 22:20:11	1.64
@@ -257,7 +257,7 @@
 	unsigned char lock_cmd;
 	unsigned char lock_flags;
 	char *args = header->node + strlen(header->node) + 1;
-	int lockid;
+	int lockid = 0;
 	int status = 0;
 	char *lockname;
 
--- LVM2/tools/lvmdiskscan.c	2011/05/28 09:48:16	1.22
+++ LVM2/tools/lvmdiskscan.c	2012/01/25 22:20:11	1.23
@@ -81,6 +81,7 @@
 	}
 	if (!dev_get_size(dev, &size)) {
 		log_error("Couldn't get size of \"%s\"", dev_name(dev));
+		size = 0;
 	}
 	_print(cmd, dev, size, NULL);
 	_count(dev, &disks_found, &parts_found);


