From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Feb 2011 23:09:58 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in lib/device/dev ...
Message-ID: <20110218230958.22543.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-18 23:09:56

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	lib/device     : dev-io.c device.h 
	lib/display    : display.c 
	libdm          : libdm-report.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Handle decimal digits with --units instead of ignoring them silently.
	Fix remaining warnings and compile with -Wpointer-arith.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1922&r2=1.1923
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2011/02/18 16:17:56	1.1922
+++ LVM2/WHATS_NEW	2011/02/18 23:09:55	1.1923
@@ -1,5 +1,7 @@
 Version 2.02.85 - 
 ===================================
+  Handle decimal digits with --units instead of ignoring them silently.
+  Fix remaining warnings and compile with -Wpointer-arith.
   Fix gcc warnings for unused variables.
   Add stack backtraces for error paths in process_each_lv().
   Fixing some const cast gcc warnings in the code.
--- LVM2/make.tmpl.in	2011/01/10 13:00:53	1.115
+++ LVM2/make.tmpl.in	2011/02/18 23:09:55	1.116
@@ -111,9 +111,9 @@
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
-CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls
+CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls -Wpointer-arith
 
-#CFLAGS += -W -Wconversion -Wpointer-arith -Wbad-function-cast -Wcast-qual
+#CFLAGS += -W -Wconversion -Wbad-function-cast -Wcast-qual
 #CFLAGS += -pedantic -std=gnu99
 #CFLAGS += -DDEBUG_CRC32
 
--- LVM2/lib/device/dev-io.c	2011/02/18 14:16:11	1.73
+++ LVM2/lib/device/dev-io.c	2011/02/18 23:09:55	1.74
@@ -57,7 +57,7 @@
  * The standard io loop that keeps submitting an io until it's
  * all gone.
  *---------------------------------------------------------------*/
-static int _io(struct device_area *where, void *buffer, int should_write)
+static int _io(struct device_area *where, char *buffer, int should_write)
 {
 	int fd = dev_fd(where->dev);
 	ssize_t n = 0;
@@ -161,10 +161,10 @@
 		result->size += block_size - delta;
 }
 
-static int _aligned_io(struct device_area *where, void *buffer,
+static int _aligned_io(struct device_area *where, char *buffer,
 		       int should_write)
 {
-	void *bounce, *bounce_buf;
+	char *bounce, *bounce_buf;
 	unsigned int block_size = 0;
 	uintptr_t mask;
 	struct device_area widened;
@@ -195,7 +195,7 @@
 	 * Realign start of bounce buffer (using the extra sector)
 	 */
 	if (((uintptr_t) bounce) & mask)
-		bounce = (void *) ((((uintptr_t) bounce) + mask) & ~mask);
+		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
 
 	/* channel the io through the bounce buffer */
 	if (!_io(&widened, bounce, 0)) {
@@ -645,7 +645,7 @@
  * 'buf' should be len+len2.
  */
 int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, void *buf)
+		      uint64_t offset2, size_t len2, char *buf)
 {
 	if (!dev_read(dev, offset, len, buf)) {
 		log_error("Read from %s failed", dev_name(dev));
@@ -673,7 +673,7 @@
  */
 
 /* FIXME pre-extend the file */
-int dev_append(struct device *dev, size_t len, void *buffer)
+int dev_append(struct device *dev, size_t len, char *buffer)
 {
 	int r;
 
--- LVM2/lib/device/device.h	2010/10/13 15:40:39	1.46
+++ LVM2/lib/device/device.h	2011/02/18 23:09:55	1.47
@@ -83,9 +83,9 @@
 
 int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer);
 int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, void *buf);
+		      uint64_t offset2, size_t len2, char *buf);
 int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer);
-int dev_append(struct device *dev, size_t len, void *buffer);
+int dev_append(struct device *dev, size_t len, char *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value);
 void dev_flush(struct device *dev);
 
--- LVM2/lib/display/display.c	2010/11/30 11:53:31	1.115
+++ LVM2/lib/display/display.c	2011/02/18 23:09:55	1.116
@@ -44,15 +44,24 @@
 {
 	char *ptr = NULL;
 	uint64_t v;
+	double custom_value = 0;
+	uint64_t multiplier;
 
 	if (isdigit(*units)) {
-		v = (uint64_t) strtod(units, &ptr);
+		custom_value = strtod(units, &ptr);
 		if (ptr == units)
 			return 0;
+		v = (uint64_t) strtoull(units, NULL, 10);
+		if ((double) v == custom_value)
+			custom_value = 0;	/* Use integer arithmetic */
 		units = ptr;
 	} else
 		v = 1;
 
+	/* Only one units char permitted. */
+	if (*(units + 1))
+		return 0;
+
 	if (v == 1)
 		*unit_type = *units;
 	else
@@ -61,65 +70,65 @@
 	switch (*units) {
 	case 'h':
 	case 'H':
-		v = UINT64_C(1);
+		multiplier = v = UINT64_C(1);
 		*unit_type = *units;
 		break;
 	case 'b':
 	case 'B':
-		v *= UINT64_C(1);
+		multiplier = UINT64_C(1);
 		break;
 #define KILO UINT64_C(1024)
 	case 's':
 	case 'S':
-		v *= (KILO/2);
+		multiplier = (KILO/2);
 		break;
 	case 'k':
-		v *= KILO;
+		multiplier = KILO;
 		break;
 	case 'm':
-		v *= KILO * KILO;
+		multiplier = KILO * KILO;
 		break;
 	case 'g':
-		v *= KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO;
 		break;
 	case 't':
-		v *= KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO;
 		break;
 	case 'p':
-		v *= KILO * KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO * KILO;
 		break;
 	case 'e':
-		v *= KILO * KILO * KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
 		break;
 #undef KILO
 #define KILO UINT64_C(1000)
 	case 'K':
-		v *= KILO;
+		multiplier = KILO;
 		break;
 	case 'M':
-		v *= KILO * KILO;
+		multiplier = KILO * KILO;
 		break;
 	case 'G':
-		v *= KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO;
 		break;
 	case 'T':
-		v *= KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO;
 		break;
 	case 'P':
-		v *= KILO * KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO * KILO;
 		break;
 	case 'E':
-		v *= KILO * KILO * KILO * KILO * KILO * KILO;
+		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
 		break;
 #undef KILO
 	default:
 		return 0;
 	}
 
-	if (*(units + 1))
-		return 0;
-
-	return v;
+	if (custom_value)
+		return (uint64_t) (custom_value * multiplier);
+	else
+		return v * multiplier;
 }
 
 const char alloc_policy_char(alloc_policy_t alloc)
--- LVM2/libdm/libdm-report.c	2011/02/18 14:38:48	1.42
+++ LVM2/libdm/libdm-report.c	2011/02/18 23:09:55	1.43
@@ -675,15 +675,15 @@
 /*
  * Create a row of data for an object
  */
-static void * _report_get_field_data(struct dm_report *rh,
-			      struct field_properties *fp, void *object)
+static void *_report_get_field_data(struct dm_report *rh,
+				    struct field_properties *fp, void *object)
 {
-	void *ret = fp->type->data_fn(object);
+	char *ret = fp->type->data_fn(object);
 
 	if (!ret)
 		return NULL;
 
-	return ret + rh->fields[fp->field_num].offset;
+	return (void *)(ret + rh->fields[fp->field_num].offset);
 }
 
 int dm_report_object(struct dm_report *rh, void *object)
--- LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 21:26:33	1.92
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/02/18 23:09:56	1.93
@@ -141,11 +141,11 @@
 #  define DM_EXISTS_FLAG 0x00000004
 #endif
 
-static void *_align(void *ptr, unsigned int a)
+static char *_align(char *ptr, unsigned int a)
 {
 	register unsigned long agn = --a;
 
-	return (void *) (((unsigned long) ptr + agn) & ~agn);
+	return (char *) (((unsigned long) ptr + agn) & ~agn);
 }
 
 static int _uname(void)
@@ -608,9 +608,9 @@
 				    dmt->dmi.v1->data_start);
 }
 
-static void *_add_target_v1(struct target *t, void *out, void *end)
+static char *_add_target_v1(struct target *t, char *out, char *end)
 {
-	void *out_sp = out;
+	char *out_sp = out;
 	struct dm_target_spec_v1 sp;
 	size_t sp_size = sizeof(struct dm_target_spec_v1);
 	int len;
@@ -629,7 +629,7 @@
 	if ((out + len + 1) >= end)
 		return_NULL;
 
-	strcpy((char *) out, t->params);
+	strcpy(out, t->params);
 	out += len + 1;
 
 	/* align next block */
@@ -650,7 +650,7 @@
 	struct dm_ioctl_v1 *dmi;
 	struct target *t;
 	size_t len = sizeof(struct dm_ioctl_v1);
-	void *b, *e;
+	char *b, *e;
 	int count = 0;
 
 	for (t = dmt->head; t; t = t->next) {
@@ -710,8 +710,8 @@
 
 	dmi->target_count = count;
 
-	b = (void *) (dmi + 1);
-	e = (void *) ((char *) dmi + len);
+	b = (char *) (dmi + 1);
+	e = (char *) dmi + len;
 
 	for (t = dmt->head; t; t = t->next)
 		if (!(b = _add_target_v1(t, b, e))) {
@@ -773,7 +773,7 @@
 		names->dev = (uint64_t) buf.st_rdev;
 		names->next = 0;
 		len = strlen(name);
-		if (((void *) (names + 1) + len + 1) >= end) {
+		if (((char *) (names + 1) + len + 1) >= end) {
 			log_error("Insufficient buffer space for device list");
 			r = 0;
 			break;
@@ -782,7 +782,7 @@
 		strcpy(names->name, name);
 
 		old_names = names;
-		names = _align((void *) ++names + len + 1, ALIGNMENT);
+		names = _align((char *) ++names + len + 1, ALIGNMENT);
 	}
 
 	if (closedir(d))
@@ -1341,9 +1341,9 @@
 	return NULL;
 }
 
-static void *_add_target(struct target *t, void *out, void *end)
+static char *_add_target(struct target *t, char *out, char *end)
 {
-	void *out_sp = out;
+	char *out_sp = out;
 	struct dm_target_spec sp;
 	size_t sp_size = sizeof(struct dm_target_spec);
 	int len;
@@ -1362,7 +1362,7 @@
 	if ((out + len + 1) >= end)
 		return_NULL;
 
-	strcpy((char *) out, t->params);
+	strcpy(out, t->params);
 	out += len + 1;
 
 	/* align next block */
@@ -1394,7 +1394,7 @@
 		goto out;
  
 	do {
-		names = (void *) names + next;
+		names = (struct dm_names *)((char *) names + next);
 		if (names->dev == dev) {
 			strncpy(buf, names->name, len);
 			r = 1;
@@ -1417,7 +1417,7 @@
 	struct target *t;
 	struct dm_target_msg *tmsg;
 	size_t len = sizeof(struct dm_ioctl);
-	void *b, *e;
+	char *b, *e;
 	int count = 0;
 
 	for (t = dmt->head; t; t = t->next) {
@@ -1565,8 +1565,8 @@
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
 
-	b = (void *) (dmi + 1);
-	e = (void *) ((char *) dmi + len);
+	b = (char *) (dmi + 1);
+	e = (char *) dmi + len;
 
 	for (t = dmt->head; t; t = t->next)
 		if (!(b = _add_target(t, b, e))) {
@@ -1652,7 +1652,7 @@
 		goto out;
 
 	do {
-		names = (void *) names + next;
+		names = (struct dm_names *)((char *) names + next);
 		if (!dm_task_set_name(dmt, names->name)) {
 			r = 0;
 			goto out;


