From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 03:16:05 -0000
Subject: LVM2/test/shell name-mangling.sh
Message-ID: <20120306031605.25140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 03:16:05

Modified files:
	test/shell     : name-mangling.sh 

Log message:
	update reworded string

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/name-mangling.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/name-mangling.sh	2012/03/05 12:49:06	1.1
+++ LVM2/test/shell/name-mangling.sh	2012/03/06 03:16:05	1.2
@@ -14,7 +14,7 @@
 
 CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#+-.:=@_"
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
-FAIL_MULTI_STR="seems to be multiple mangled"
+FAIL_MULTI_STR="seems to be mangled more than once"
 FAIL_BLACK_STR="should be mangled but it contains blacklisted characters"
 CORRECT_FORM_STR="name already in correct form"
 RENAMING_STR="renaming to"


