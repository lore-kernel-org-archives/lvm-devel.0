From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jun 2011 13:42:16 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110628134216.15351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-28 13:42:15

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2028&r2=1.2029
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2011/06/28 00:23:06	1.2028
+++ LVM2/WHATS_NEW	2011/06/28 13:42:15	1.2029
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd.
   Remove enforcement of udev verification when using non-standard /dev location.
   Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
--- LVM2/daemons/clvmd/clvmd.c	2011/04/08 14:40:18	1.104
+++ LVM2/daemons/clvmd/clvmd.c	2011/06/28 13:42:15	1.105
@@ -295,6 +295,9 @@
 	case CLVMD_CMD_RESTART:
 		command = "RESTART";
 		break;
+	case CLVMD_CMD_SYNC_NAMES:
+		command = "SYNC_NAMES";
+		break;
 	default:
 		command = "unknown";
 		break;


