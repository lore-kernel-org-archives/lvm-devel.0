From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:28:05 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm_base.c
Message-ID: <20101220132805.16011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:28:05

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm_base.c 

Log message:
	Fix wrong cast to char*
	
	As cmd->cmd_line is already const char pointer it's not needed to cast already
	const char pointer to char pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1841&r2=1.1842
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2010/12/20 13:17:56	1.1841
+++ LVM2/WHATS_NEW	2010/12/20 13:28:04	1.1842
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Fixing const cast gcc warnings in the code.
   Check read() and close() results in _get_cmdline().
   Add const for struct config_node usage.
   Fix NULL pointer check in error path in clvmd do_command(). (2.02.78)
--- LVM2/liblvm/lvm_base.c	2010/12/14 23:20:58	1.19
+++ LVM2/liblvm/lvm_base.c	2010/12/20 13:28:04	1.20
@@ -61,7 +61,7 @@
 	 * archive() call.  Possible example:
 	 * cmd_line = "lvm_vg_create: vg1\nlvm_vg_extend vg1 /dev/sda1\n"
 	 */
-	cmd->cmd_line = (char *)"liblvm";
+	cmd->cmd_line = "liblvm";
 
 	return (lvm_t) cmd;
 }


