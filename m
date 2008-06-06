From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 16:37:52 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20080606163752.7793.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 16:37:52

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	cleaner LCK_LV decoding

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/daemons/clvmd/lvm-functions.c	2008/06/05 14:24:28	1.43
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/06/06 16:37:51	1.44
@@ -61,6 +61,8 @@
 	int lock_mode;
 };
 
+#define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
+
 static const char *decode_locking_cmd(unsigned char cmdl)
 {
 	static char buf[128];
@@ -104,23 +106,20 @@
 		break;
 	}
 
-	switch (cmdl) {
-	case LCK_LV_EXCLUSIVE:  
+	switch (cmdl & LCK_MASK) {
+	case LCK_LV_EXCLUSIVE & LCK_MASK:
 		command = "LCK_LV_EXCLUSIVE";  
 		break;
-	case LCK_LV_SUSPEND:    
+	case LCK_LV_SUSPEND & LCK_MASK:    
 		command = "LCK_LV_SUSPEND";    
 		break;
-	case LCK_LV_UNLOCK:        
-		command = "LCK_LV_UNLOCK";     
-		break;
-	case LCK_LV_RESUME:     
+	case LCK_LV_RESUME & LCK_MASK:     
 		command = "LCK_LV_RESUME";     
 		break;
-	case LCK_LV_ACTIVATE:   
+	case LCK_LV_ACTIVATE & LCK_MASK:   
 		command = "LCK_LV_ACTIVATE";   
 		break;
-	case LCK_LV_DEACTIVATE: 
+	case LCK_LV_DEACTIVATE & LCK_MASK: 
 		command = "LCK_LV_DEACTIVATE"; 
 		break;
 	default:


