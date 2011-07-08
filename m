From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 12:35:49 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20110708123549.18891.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 12:35:48

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	report which dev was not found

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2011/04/04 16:11:09	1.41
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2011/07/08 12:35:48	1.42
@@ -559,10 +559,19 @@
 	}
 
 	if (!info.exists) {
-		log_error("_get_device_info: device not found");
+		log_error("_get_device_info: %s%s%s%.0d%s%.0d%s%s: device not found",
+			  dmevh->uuid ? : "", 
+			  (!dmevh->uuid && dmevh->dev_name) ? dmevh->dev_name : "", 
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? "(" : "",
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? dmevh->major : 0,
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? ":" : "",
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->minor > 0) ? dmevh->minor : 0,
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) && dmevh->minor == 0 ? "0" : "",
+			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? ") " : "");
 		goto bad;
 	}
 
+		  
 	return dmt;
 
       bad:


