From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Aug 2008 14:01:18 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20080807140118.29068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-07 14:01:18

Modified files:
	lib/display    : display.c 

Log message:
	added const modifiers
	switched const char* to  const char[] elements to save few relocation entries

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/lib/display/display.c	2008/04/10 19:16:35	1.90
+++ LVM2/lib/display/display.c	2008/08/07 14:01:17	1.91
@@ -24,9 +24,9 @@
 
 typedef enum { SIZE_LONG = 0, SIZE_SHORT = 1, SIZE_UNIT = 2 } size_len_t;
 
-static struct {
+static const struct {
 	alloc_policy_t alloc;
-	const char *str;
+	const char str[12]; /* must be changed when size extends 11 chars */
 } _policies[] = {
 	{
 	ALLOC_CONTIGUOUS, "contiguous"}, {
@@ -36,7 +36,7 @@
 	ALLOC_INHERIT, "inherit"}
 };
 
-static int _num_policies = sizeof(_policies) / sizeof(*_policies);
+static const int _num_policies = sizeof(_policies) / sizeof(*_policies);
 
 uint64_t units_to_bytes(const char *units, char *unit_type)
 {
@@ -155,7 +155,7 @@
 	uint64_t byte = UINT64_C(0);
 	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
-	const char *size_str[][3] = {
+	const char * const size_str[][3] = {
 		{" Exabyte", " EB", "E"},
 		{" Petabyte", " PB", "P"},
 		{" Terabyte", " TB", "T"},


