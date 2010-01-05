From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:03:38 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100105160338.27427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:03:38

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : cluster_locking.c 

Log message:
	Properly decode flags even for VG locks.
	
	And decode flags in humar readable form in client.
	And clean some trailing whitespaces.
	
	No functional change in this patch (only debugging messages changed).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1356&r2=1.1357
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2010/01/05 16:01:22	1.1356
+++ LVM2/WHATS_NEW	2010/01/05 16:03:37	1.1357
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Properly decode flags even for VG locks.
   Properly handle precommitted flag in cache when commited data only present.
   Resume renamed volumes in reverse order to preserve memlock pairing.
   Drop metadata cache after device was autorepaired and removed from VG.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:30:56	1.78
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:03:37	1.79
@@ -74,23 +74,23 @@
 	const char *command;
 
 	switch (cmdl & LCK_TYPE_MASK) {
-	case LCK_NULL:   
-		type = "NULL";   
+	case LCK_NULL:
+		type = "NULL";
 		break;
-	case LCK_READ:   
-		type = "READ";   
+	case LCK_READ:
+		type = "READ";
 		break;
-	case LCK_PREAD:  
-		type = "PREAD";  
+	case LCK_PREAD:
+		type = "PREAD";
 		break;
-	case LCK_WRITE:  
-		type = "WRITE";  
+	case LCK_WRITE:
+		type = "WRITE";
 		break;
-	case LCK_EXCL:   
-		type = "EXCL";   
+	case LCK_EXCL:
+		type = "EXCL";
 		break;
-	case LCK_UNLOCK: 
-		type = "UNLOCK"; 
+	case LCK_UNLOCK:
+		type = "UNLOCK";
 		break;
 	default:
 		type = "unknown";
@@ -98,34 +98,35 @@
 	}
 
 	switch (cmdl & LCK_SCOPE_MASK) {
-	case LCK_VG: 
-		scope = "VG"; 
+	case LCK_VG:
+		scope = "VG";
+		command = "LCK_VG";
 		break;
-	case LCK_LV: 
+	case LCK_LV:
 		scope = "LV"; 
+		switch (cmdl & LCK_MASK) {
+		case LCK_LV_EXCLUSIVE & LCK_MASK:
+			command = "LCK_LV_EXCLUSIVE";
+			break;
+		case LCK_LV_SUSPEND & LCK_MASK:
+			command = "LCK_LV_SUSPEND";
+			break;
+		case LCK_LV_RESUME & LCK_MASK:
+			command = "LCK_LV_RESUME";
+			break;
+		case LCK_LV_ACTIVATE & LCK_MASK:
+			command = "LCK_LV_ACTIVATE";
+			break;
+		case LCK_LV_DEACTIVATE & LCK_MASK:
+			command = "LCK_LV_DEACTIVATE";
+			break;
+		default:
+			command = "unknown";
+			break;
+		}
 		break;
 	default:
 		scope = "unknown";
-		break;
-	}
-
-	switch (cmdl & LCK_MASK) {
-	case LCK_LV_EXCLUSIVE & LCK_MASK:
-		command = "LCK_LV_EXCLUSIVE";  
-		break;
-	case LCK_LV_SUSPEND & LCK_MASK:    
-		command = "LCK_LV_SUSPEND";    
-		break;
-	case LCK_LV_RESUME & LCK_MASK:     
-		command = "LCK_LV_RESUME";     
-		break;
-	case LCK_LV_ACTIVATE & LCK_MASK:   
-		command = "LCK_LV_ACTIVATE";   
-		break;
-	case LCK_LV_DEACTIVATE & LCK_MASK: 
-		command = "LCK_LV_DEACTIVATE"; 
-		break;
-	default:
 		command = "unknown";
 		break;
 	}
--- LVM2/lib/locking/cluster_locking.c	2009/12/09 18:28:27	1.38
+++ LVM2/lib/locking/cluster_locking.c	2010/01/05 16:03:37	1.39
@@ -450,12 +450,13 @@
 		return 0;
 	}
 
-	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
-			 lock_type,
-			 flags & LCK_NONBLOCK ? "" : "B",
-			 flags & LCK_HOLD ? "H" : "",
-			 flags & LCK_LOCAL ? "L" : "",
-			 flags & LCK_CLUSTER_VG ? "C" : "",
+	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
+			 lock_type, lock_scope,
+			 flags & LCK_NONBLOCK ? "|NONBLOCK" : "",
+			 flags & LCK_HOLD ? "|HOLD" : "",
+			 flags & LCK_LOCAL ? "|LOCAL" : "",
+			 flags & LCK_CLUSTER_VG ? "|CLUSTER" : "",
+			 flags & LCK_CACHE ? "|CACHE" : "",
 			 flags);
 
 	/* Send a message to the cluster manager */


