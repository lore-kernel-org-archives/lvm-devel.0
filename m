From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:17:35 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20120215121735.17979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:17:35

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Replace any '\' char with '\\' in table specification on input.
	
	Device-mapper in kernel uses '\' as escape character so it's better
	to double it to avoid any confusion when using existing device names
	with '\' in the table specification.
	
	For example:
	
	dmsetup create x --table "0 8 linear /dev/mapper/a\x20b 0"
	
	should pass just fine now without a need to explicitly escape the '\' char
	like this:
	
	dmsetup create x --table "0 8 linear /dev/mapper/a\\x20b 0"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.563&r2=1.564
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/WHATS_NEW_DM	2012/02/15 12:08:57	1.563
+++ LVM2/WHATS_NEW_DM	2012/02/15 12:17:34	1.564
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Replace any '\' char with '\\' in table specification on input.
   Add mangle command to dmsetup to provide renaming to correct mangled form.
   Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.
   Add --manglename option to dmsetup to select the name mangling mode.
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 12:01:28	1.137
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 12:17:34	1.138
@@ -866,7 +866,9 @@
 	char *out_sp = out;
 	struct dm_target_spec sp;
 	size_t sp_size = sizeof(struct dm_target_spec);
+	unsigned int backslash_count = 0;
 	int len;
+	char *pt;
 
 	if (strlen(t->type) >= sizeof(sp.target_type)) {
 		log_error("Target type name %s is too long.", t->type);
@@ -880,15 +882,32 @@
 	sp.target_type[sizeof(sp.target_type) - 1] = '\0';
 
 	out += sp_size;
-	len = strlen(t->params);
+	pt = t->params;
+
+	while (*pt)
+		if (*pt++ == '\\')
+			backslash_count++;
+	len = strlen(t->params) + backslash_count;
 
 	if ((out >= end) || (out + len + 1) >= end) {
 		log_error("Ran out of memory building ioctl parameter");
 		return NULL;
 	}
 
-	strcpy(out, t->params);
-	out += len + 1;
+	if (backslash_count) {
+		/* replace "\" with "\\" */
+		pt = t->params;
+		do {
+			if (*pt == '\\')
+				*out++ = '\\';
+			*out++ = *pt++;
+		} while (*pt);
+		*out++ = '\0';
+	}
+	else {
+		strcpy(out, t->params);
+		out += len + 1;
+	}
 
 	/* align next block */
 	out = _align(out, ALIGNMENT);


