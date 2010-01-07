From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:47:57 -0000
Subject: LVM2/lib/format_text flags.c
Message-ID: <20100107144757.30787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:47:57

Modified files:
	lib/format_text: flags.c 

Log message:
	Add few const modifiers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/lib/format_text/flags.c	2009/11/24 22:55:56	1.38
+++ LVM2/lib/format_text/flags.c	2010/01/07 14:47:57	1.39
@@ -28,7 +28,7 @@
 	int kind;
 };
 
-static struct flag _vg_flags[] = {
+static const struct flag _vg_flags[] = {
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{RESIZEABLE_VG, "RESIZEABLE", STATUS_FLAG},
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
@@ -41,14 +41,14 @@
 	{0, NULL, 0}
 };
 
-static struct flag _pv_flags[] = {
+static const struct flag _pv_flags[] = {
 	{ALLOCATABLE_PV, "ALLOCATABLE", STATUS_FLAG},
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{MISSING_PV, "MISSING", COMPATIBLE_FLAG},
 	{0, NULL, 0}
 };
 
-static struct flag _lv_flags[] = {
+static const struct flag _lv_flags[] = {
 	{LVM_READ, "READ", STATUS_FLAG},
 	{LVM_WRITE, "WRITE", STATUS_FLAG},
 	{FIXED_MINOR, "FIXED_MINOR", STATUS_FLAG},
@@ -69,7 +69,7 @@
 	{0, NULL, 0}
 };
 
-static struct flag *_get_flags(int type)
+static const struct flag *_get_flags(int type)
 {
 	switch (type & ~STATUS_FLAG) {
 	case VG_FLAGS:
@@ -94,7 +94,7 @@
 int print_flags(uint64_t status, int type, char *buffer, size_t size)
 {
 	int f, first = 1;
-	struct flag *flags;
+	const struct flag *flags;
 
 	if (!(flags = _get_flags(type)))
 		return_0;
@@ -139,7 +139,7 @@
 {
 	int f;
 	uint64_t s = UINT64_C(0);
-	struct flag *flags;
+	const struct flag *flags;
 
 	if (!(flags = _get_flags(type)))
 		return_0;


