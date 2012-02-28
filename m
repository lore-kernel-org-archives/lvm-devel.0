From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 10:11:36 -0000
Subject: LVM2/lib filters/filter.c format_text/format-t ...
Message-ID: <20120228101136.16669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 10:11:36

Modified files:
	lib/filters    : filter.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Add some stack traces for dev_close error paths

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.488&r2=1.489

--- LVM2/lib/filters/filter.c	2012/02/13 10:45:26	1.69
+++ LVM2/lib/filters/filter.c	2012/02/28 10:11:35	1.70
@@ -179,7 +179,8 @@
 	ret = 1;
 
       out:
-	dev_close(dev);
+	if (!dev_close(dev))
+		stack;
 
 	return ret;
 }
--- LVM2/lib/format_text/format-text.c	2012/02/27 09:54:25	1.196
+++ LVM2/lib/format_text/format-text.c	2012/02/28 10:11:36	1.197
@@ -1357,8 +1357,10 @@
 		return_0;
 
 	if (!label_write(pv->dev, label)) {
-		dev_close(pv->dev);
-		return_0;
+		stack;
+		if (!dev_close(pv->dev))
+			stack;
+		return 0;
 	}
 
 	/*
--- LVM2/lib/metadata/metadata.c	2012/02/27 11:36:00	1.488
+++ LVM2/lib/metadata/metadata.c	2012/02/28 10:11:36	1.489
@@ -1460,10 +1460,12 @@
 
 		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
 			log_error("%s not wiped: aborting", pv_name);
-			dev_close(dev);
+			if (!dev_close(dev))
+				stack;
 			return 0;
 		}
-		dev_close(dev);
+		if (!dev_close(dev))
+			stack;
 	}
 
 	log_error("Writing physical volume data to disk \"%s\"",


