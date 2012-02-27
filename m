From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:17:07 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120227101707.19011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:17:06

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	A bit more safe version of sprintf
	
	Use just buffer size limit (it's used for debug only)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/daemons/clvmd/clvmd.c	2012/02/27 09:58:19	1.121
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/27 10:17:06	1.122
@@ -303,7 +303,7 @@
 		break;
 	}
 
-	sprintf(buf, "%s (0x%x)", command, cmdl);
+	snprintf(buf, sizeof(buf), "%s (0x%x)", command, cmdl);
 
 	return buf;
 }


