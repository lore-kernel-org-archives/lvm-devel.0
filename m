From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 14:30:54 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-exec.c lib/repor ...
Message-ID: <20110804143054.13747.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 14:30:52

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-exec.c 
	lib/report     : report.c 
	libdm          : libdm-report.c 

Log message:
	Remove meaningless const type qualifiers on cast type
	
	Static analyzis noticed we do not really need them - so removing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2050&r2=1.2051
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2011/08/04 12:40:25	1.2050
+++ LVM2/WHATS_NEW	2011/08/04 14:30:51	1.2051
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Remove meaningless const type qualifiers on cast type.
   Fix memory leak in dmsetup _message() memory allocation error path.
   Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
--- LVM2/lib/misc/lvm-exec.c	2011/01/13 14:51:33	1.12
+++ LVM2/lib/misc/lvm-exec.c	2011/08/04 14:30:51	1.13
@@ -75,7 +75,7 @@
 		/* FIXME Fix effect of reset_locking on cache then include this */
 		/* destroy_toolcontext(cmd); */
 		/* FIXME Use execve directly */
-		execvp(argv[0], (char **const) argv);
+		execvp(argv[0], (char **) argv);
 		log_sys_error("execvp", argv[0]);
 		_exit(errno);
 	}
--- LVM2/lib/report/report.c	2011/04/12 12:24:29	1.144
+++ LVM2/lib/report/report.c	2011/08/04 14:30:52	1.145
@@ -350,7 +350,7 @@
 		return 0;
 	}
 
-	*sortval = (const uint64_t) size;
+	*sortval = (uint64_t) size;
 
 	dm_report_field_set_value(field, repstr, sortval);
 
--- LVM2/libdm/libdm-report.c	2011/06/12 19:49:41	1.45
+++ LVM2/libdm/libdm-report.c	2011/08/04 14:30:52	1.46
@@ -139,7 +139,7 @@
 		return 0;
 	}
 
-	*sortval = (const uint64_t) value;
+	*sortval = (uint64_t) value;
 	field->sort_value = sortval;
 	field->report_string = repstr;
 
@@ -168,7 +168,7 @@
 		return 0;
 	}
 
-	*sortval = (const uint64_t) value;
+	*sortval = (uint64_t) value;
 	field->sort_value = sortval;
 	field->report_string = repstr;
 
@@ -197,7 +197,7 @@
 		return 0;
 	}
 
-	*sortval = (const uint64_t) value;
+	*sortval = (uint64_t) value;
 	field->sort_value = sortval;
 	field->report_string = repstr;
 


