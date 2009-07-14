From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 03:01:18 -0000
Subject: LVM2/liblvm lvm_base.c
Message-ID: <20090714030118.5342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 03:01:18

Modified files:
	liblvm         : lvm_base.c 

Log message:
	Add default cmd->cmd_line initialization for liblvm lvm_create().
	
	This needs initialized to non-NULL before using the archive() call.
	Normally this is set to the cmdline string when lvm is called from a tool.
	We could think about using it in another way, as a potential audit trail
	of liblvm calls, or just leave it set to the default "liblvm", similar to
	what clvmd does.  For now, just set it to "liblvm".
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/liblvm/lvm_base.c	2009/03/10 15:38:46	1.2
+++ LVM2/liblvm/lvm_base.c	2009/07/14 03:01:18	1.3
@@ -45,6 +45,12 @@
 		lvm_destroy((lvm_t) cmd);
 		return NULL;
 	}
+	/*
+	 * FIXME: Use cmd->cmd_line as audit trail for liblvm calls.  Used in
+	 * archive() call.  Possible example:
+	 * cmd_line = "lvm_vg_create: vg1\nlvm_vg_extend vg1 /dev/sda1\n"
+	 */
+	cmd->cmd_line = (char *)"liblvm";
 
 	return (lvm_t) cmd;
 }


