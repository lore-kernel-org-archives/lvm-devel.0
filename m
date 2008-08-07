From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Aug 2008 14:02:33 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20080807140233.29537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-07 14:02:32

Modified files:
	lib/config     : config.c 

Log message:
	* more strict const

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/lib/config/config.c	2008/07/31 13:06:55	1.70
+++ LVM2/lib/config/config.c	2008/08/07 14:02:32	1.71
@@ -1011,7 +1011,7 @@
 	return _find_config_float(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
 }
 
-static int _str_in_array(const char *str, const char *values[])
+static int _str_in_array(const char *str, const char * const values[])
 {
 	int i;
 
@@ -1024,9 +1024,8 @@
 
 static int _str_to_bool(const char *str, int fail)
 {
-	static const char *_true_values[] = { "y", "yes", "on", "true", NULL };
-	static const char *_false_values[] =
-	    { "n", "no", "off", "false", NULL };
+	const char * const _true_values[]  = { "y", "yes", "on", "true", NULL };
+	const char * const _false_values[] = { "n", "no", "off", "false", NULL };
 
 	if (_str_in_array(str, _true_values))
 		return 1;


