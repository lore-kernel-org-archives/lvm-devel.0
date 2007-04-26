From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Apr 2007 16:40:46 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/datas ...
Message-ID: <20070426164046.18648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-26 17:40:46

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/datastruct : lvm-types.h 

Log message:
	Fix warnings on x86_64 involving ptrdiff_t:
	config/config.c:493: warning: format '%d' expects type 'int', but argument 5 has type 'long int'
	
	Modified original patch from Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.605&r2=1.606
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2007/04/25 21:10:55	1.605
+++ LVM2/WHATS_NEW	2007/04/26 16:40:45	1.606
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Fix warnings on x86_64 involving ptrdiff_t in log_error messages
   Update pvck to include text metadata area and record detection
   Add support functions for analysis of config sections
   Update pvck to read labels on disk, with --labelsector parameter
--- LVM2/lib/config/config.c	2007/04/25 20:38:39	1.56
+++ LVM2/lib/config/config.c	2007/04/26 16:40:46	1.57
@@ -83,7 +83,8 @@
 
 #define match(t) do {\
    if (!_match_aux(p, (t))) {\
-	log_error("Parse error at byte %d (line %d): unexpected token", p->tb - p->fb + 1, p->line); \
+	log_error("Parse error at byte %" PRIptrdiff_t " (line %d): unexpected token", \
+		  p->tb - p->fb + 1, p->line); \
       return 0;\
    } \
 } while(0);
@@ -590,7 +591,8 @@
 		break;
 
 	default:
-		log_error("Parse error at byte %d (line %d): expected a value", p->tb - p->fb + 1, p->line);
+		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
+			  p->tb - p->fb + 1, p->line);
 		return 0;
 	}
 	return v;
--- LVM2/lib/datastruct/lvm-types.h	2005/05/09 17:45:06	1.11
+++ LVM2/lib/datastruct/lvm-types.h	2007/04/26 16:40:46	1.12
@@ -23,6 +23,7 @@
 
 /* Define some portable printing types */
 #define PRIsize_t "zu"
+#define PRIptrdiff_t "td"
 
 struct str_list {
 	struct list list;


