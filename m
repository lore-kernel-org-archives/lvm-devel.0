From: maximilian attems <max@stro.at>
Date: Wed, 15 Aug 2007 18:33:17 +0200
Subject: [patch] lvm2 kill strings.h include
Message-ID: <20070815163317.GC18069@stro.at>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

klibc has no strings.h and to quote hpa:
"Including <strings.h> is a bug in the upstream source;                       
<strings.h> has been obsolete since at least 1989"                            

Signed-off-by: maximilian attems <max@stro.at>

Index: configure
===================================================================
RCS file: /cvs/lvm2/LVM2/configure,v
retrieving revision 1.59
diff -u -r1.59 configure
--- configure	14 Aug 2007 18:58:30 -0000	1.59
+++ configure	15 Aug 2007 16:34:49 -0000
@@ -600,9 +600,6 @@
 # endif
 # include <string.h>
 #endif
-#ifdef HAVE_STRINGS_H
-# include <strings.h>
-#endif
 #ifdef HAVE_INTTYPES_H
 # include <inttypes.h>
 #endif
@@ -4183,7 +4180,7 @@
 
 
 
-for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
+for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h \
 		  inttypes.h stdint.h unistd.h
 do
 as_ac_Header=`echo "ac_cv_header_$ac_header" | $as_tr_sh`

-- 
maks


