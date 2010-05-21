From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: 21 May 2010 15:28:21 -0000
Subject: LVM2 ./WHATS_NEW scripts/relpath.awk
Message-ID: <20100521152821.16681.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2010-05-21 15:28:16

Modified files:
	.              : WHATS_NEW 
	scripts        : relpath.awk 

Log message:
	Fix scripts/relpath.awk to work with mawk
	
	length(array) is specific to GNU awk and doesn't work in mawk.
	Use a return value of "split" function to indicate array size, this is
	supported in both gawk and mawk.
	
	This patch fixes the following errors during "make install" when mawk is
	installed as a default awk.
	
	mawk: scripts/relpath.awk: line 25: illegal reference to array from
	mawk: scripts/relpath.awk: line 25: illegal reference to array to
	mawk: scripts/relpath.awk: line 27: illegal reference to array from
	mawk: scripts/relpath.awk: line 32: illegal reference to array to
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1590&r2=1.1591
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/relpath.awk.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/05/21 14:47:58	1.1590
+++ LVM2/WHATS_NEW	2010/05/21 15:28:16	1.1591
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Fixed scripts/relpath.awk to work in mawk
   Add _add_partial_replicator_to_dtree().
   Activation code read and releases also remote VGs (Replicator).
   Check for missing VGs before taking lock_vol (Replicator).
--- LVM2/scripts/relpath.awk	2010/04/30 14:49:45	1.3
+++ LVM2/scripts/relpath.awk	2010/05/21 15:28:16	1.4
@@ -19,17 +19,17 @@
 # -> ../../e/f/
 
 {
-	split($1, from, "/");
-	split($2, to, "/") ;
+	length_from = split($1, from, "/");
+	length_to = split($2, to, "/") ;
 	l = 1;
-	while (l <= length(from) && l <= length(to) && from[l] == to[l])
+	while (l <= length_from && l <= length_to && from[l] == to[l])
 		l++;
-	for (i = l; i <= length(from) && length(from[i]); i++) {
+	for (i = l; i <= length_from && length(from[i]); i++) {
 		if (i > l)
 			p = sprintf("%s/", p);
 		p = sprintf("%s..", p);
 	}
-	for (i = l; i <= length(to) && length(to[i]); i++) {
+	for (i = l; i <= length_to && length(to[i]); i++) {
 		if (length(p) > 0)
 			p = sprintf("%s/", p);
 		p = sprintf("%s%s", p, to[i]);


