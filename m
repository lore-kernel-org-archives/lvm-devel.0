From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:37:27 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c tools ...
Message-ID: <20101220133727.7391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:37:27

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	tools          : dmsetup.c 

Log message:
	Switch void* to char* arithmetic

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1842&r2=1.1843
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/WHATS_NEW	2010/12/20 13:28:04	1.1842
+++ LVM2/WHATS_NEW	2010/12/20 13:37:26	1.1843
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Use char* arithmetic in target_version(), _process_all(), _targets().
   Fixing const cast gcc warnings in the code.
   Check read() and close() results in _get_cmdline().
   Add const for struct config_node usage.
--- LVM2/lib/activate/activate.c	2010/12/20 13:12:55	1.183
+++ LVM2/lib/activate/activate.c	2010/12/20 13:37:26	1.184
@@ -398,7 +398,7 @@
 			goto out;
 		}
 
-		target = (void *) target + target->next;
+		target = (struct dm_versions *)((char *) target + target->next);
 	} while (last_target != target);
 
       out:
--- LVM2/tools/dmsetup.c	2010/11/30 22:53:37	1.149
+++ LVM2/tools/dmsetup.c	2010/12/20 13:37:26	1.150
@@ -1288,8 +1288,8 @@
 	}
 
 	do {
-		names = (void *) names + next;
-		if (!fn(argc, argv, (void *) names))
+		names = (struct dm_names *)((char *) names + next);
+		if (!fn(argc, argv, names))
 			r = 0;
 		next = names->next;
 	} while (next);
@@ -1632,7 +1632,7 @@
 		printf("%-16s v%d.%d.%d\n", target->name, target->version[0],
 		       target->version[1], target->version[2]);
 
-		target = (void *) target + target->next;
+		target = (struct dm_versions *)((char *) target + target->next);
 	} while (last_target != target);
 
 	r = 1;


