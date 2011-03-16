From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 15 Mar 2011 19:31:35 -0500
Subject: [PATCH 1 of 1] LVM: fix macro call
Message-ID: <201103160031.p2G0VZFZ028034@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-fix-macro-call.patch

This 'bug' has been around for more than 5 years... originally put in here:
http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?r1=1.93&r2=1.94&cvsroot=lvm2&f=h

Thing is, I'm not sure how it was ever suppose to work - it's the wrong type
of argument to the macro.  Perhaps the macro has changed, or perhaps I just don't
get it.

Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -346,7 +346,7 @@ static int _lvcreate_params(struct lvcre
 	lp->mirrors = 1;
 
 	/* Default to 2 mirrored areas if --type mirror */
-	if (seg_is_mirrored(lp))
+	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
 	if (arg_count(cmd, mirrors_ARG)) {


