From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2010 19:15:14 -0000
Subject: LVM2/lib/device dev-io.c
Message-ID: <20100927191514.24881.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-27 19:15:13

Modified files:
	lib/device     : dev-io.c 

Log message:
	drop an unnecessary 'stack'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/lib/device/dev-io.c	2010/09/22 22:31:46	1.70
+++ LVM2/lib/device/dev-io.c	2010/09/27 19:15:13	1.71
@@ -210,8 +210,10 @@
 		       (size_t) where->size);
 
 		/* ... then we write */
-		r = _io(&widened, bounce, 1);
-		goto_out;
+		if (!(r = _io(&widened, bounce, 1)))
+			stack;
+			
+		goto out;
 	}
 
 	memcpy(buffer, bounce + (where->start - widened.start),


