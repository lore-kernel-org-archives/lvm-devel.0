From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Apr 2009 10:38:21 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20090422103821.3827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-22 10:38:20

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Clean a lot of extra extra whitespaces.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/daemons/clvmd/clvmd.c	2009/03/24 11:49:15	1.56
+++ LVM2/daemons/clvmd/clvmd.c	2009/04/22 10:38:16	1.57
@@ -221,44 +221,44 @@
 	const char *command;
 
 	switch (cmdl) {
-	case CLVMD_CMD_TEST:		
-		command = "TEST";	
+	case CLVMD_CMD_TEST:
+		command = "TEST";
 		break;
-	case CLVMD_CMD_LOCK_VG:		
-		command = "LOCK_VG";	
+	case CLVMD_CMD_LOCK_VG:
+		command = "LOCK_VG";
 		break;
-	case CLVMD_CMD_LOCK_LV:		
-		command = "LOCK_LV";	
+	case CLVMD_CMD_LOCK_LV:
+		command = "LOCK_LV";
 		break;
-	case CLVMD_CMD_REFRESH:		
-		command = "REFRESH";	
+	case CLVMD_CMD_REFRESH:
+		command = "REFRESH";
 		break;
-	case CLVMD_CMD_SET_DEBUG:	
-		command = "SET_DEBUG";	
+	case CLVMD_CMD_SET_DEBUG:
+		command = "SET_DEBUG";
 		break;
-	case CLVMD_CMD_GET_CLUSTERNAME:	
+	case CLVMD_CMD_GET_CLUSTERNAME:
 		command = "GET_CLUSTERNAME";
 		break;
-	case CLVMD_CMD_VG_BACKUP:	
-		command = "VG_BACKUP";	
+	case CLVMD_CMD_VG_BACKUP:
+		command = "VG_BACKUP";
 		break;
-	case CLVMD_CMD_REPLY:		
-		command = "REPLY";	
+	case CLVMD_CMD_REPLY:
+		command = "REPLY";
 		break;
-	case CLVMD_CMD_VERSION:		
-		command = "VERSION";	
+	case CLVMD_CMD_VERSION:
+		command = "VERSION";
 		break;
-	case CLVMD_CMD_GOAWAY:		
-		command = "GOAWAY";	
+	case CLVMD_CMD_GOAWAY:
+		command = "GOAWAY";
 		break;
-	case CLVMD_CMD_LOCK:		
-		command = "LOCK";	
+	case CLVMD_CMD_LOCK:
+		command = "LOCK";
 		break;
-	case CLVMD_CMD_UNLOCK:		
-		command = "UNLOCK";	
+	case CLVMD_CMD_UNLOCK:
+		command = "UNLOCK";
 		break;
-	default:			
-		command = "unknown";    
+	default:
+		command = "unknown";
 		break;
 	}
 


