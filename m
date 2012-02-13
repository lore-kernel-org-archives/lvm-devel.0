From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:18:47 -0000
Subject: LVM2 daemons/dmeventd/dmeventd.c ./WHATS_NEW_DM
Message-ID: <20120213111847.19043.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:18:46

Modified files:
	daemons/dmeventd: dmeventd.c 
	.              : WHATS_NEW_DM 

Log message:
	Check for allocation failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.553&r2=1.554

--- LVM2/daemons/dmeventd/dmeventd.c	2012/02/10 13:46:23	1.88
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/02/13 11:18:45	1.89
@@ -1782,9 +1782,16 @@
 		}
 	}
 
-	_initial_registrations = dm_malloc(sizeof(char*) * (count + 1));
+	if (!(_initial_registrations = dm_malloc(sizeof(char*) * (count + 1)))) {
+		fprintf(stderr, "Memory allocation registration failed.\n");
+		exit(EXIT_FAILURE);
+	}
+
 	for (i = 0; i < count; ++i) {
-		_initial_registrations[i] = dm_strdup(message);
+		if (!(_initial_registrations[i] = dm_strdup(message))) {
+			fprintf(stderr, "Memory allocation for message failed.\n");
+			exit(EXIT_FAILURE);
+		}
 		message += strlen(message) + 1;
 	}
 	_initial_registrations[count] = 0;
--- LVM2/WHATS_NEW_DM	2012/02/13 11:13:44	1.553
+++ LVM2/WHATS_NEW_DM	2012/02/13 11:18:46	1.554
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Check for allocation failure in dmeventd restart().
   Add few missing allocation failures tests in dmsetup.
   Fix potential risk of writing in front of buffer in _sysfs_get_dm_name().
 


