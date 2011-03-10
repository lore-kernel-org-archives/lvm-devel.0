From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 14:51:36 -0000
Subject: LVM2 lib/config/config.c ./WHATS_NEW
Message-ID: <20110310145136.24528.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 14:51:36

Modified files:
	lib/config     : config.c 
	.              : WHATS_NEW 

Log message:
	Optimise _eat_space and _get_token
	
	Makes the code more readable and has a smaller number of memory
	accesses thus it's small optimisation as well.
	
	For _get_token() optimize number parsing. Check for '.' char only
	if it's not a digit. Move pointer incrementation into one place.
	
	For _eat_space() check only p->te for '\0' in skipping of comment line.
	Avoid check for '\0' when we know it is space. Also master while loop
	doesn't need checking p->tb for '\0'. We just need to check p->tb
	isn't already at the end of buffer. This could give 'extra' loop cycle
	if we are already there - but safes memory access in every other case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1943&r2=1.1944

--- LVM2/lib/config/config.c	2011/02/28 19:53:03	1.90
+++ LVM2/lib/config/config.c	2011/03/10 14:51:35	1.91
@@ -822,18 +822,20 @@
 	case '+':
 	case '-':
 		if (values_allowed) {
-			te++;
-			while ((te != p->fe) && (*te)) {
-				if (*te == '.') {
-					if (p->t == TOK_FLOAT)
-						break;
-					p->t = TOK_FLOAT;
-				} else if (!isdigit((int) *te))
+			while (++te != p->fe) {
+				if (!isdigit((int) *te)) {
+					if (*te == '.') {
+						if (p->t != TOK_FLOAT) {
+							p->t = TOK_FLOAT;
+							continue;
+						}
+					}
 					break;
-				te++;
+				}
 			}
 			break;
 		}
+		/* fall through */
 
 	default:
 		p->t = TOK_IDENTIFIER;
@@ -850,21 +852,19 @@
 
 static void _eat_space(struct parser *p)
 {
-	while ((p->tb != p->fe) && (*p->tb)) {
+	while (p->tb != p->fe) {
 		if (*p->te == '#')
-			while ((p->te != p->fe) && (*p->te) && (*p->te != '\n'))
-				p->te++;
+			while ((p->te != p->fe) && (*p->te != '\n') && (*p->te))
+				++p->te;
 
-		else if (isspace(*p->te)) {
-			while ((p->te != p->fe) && (*p->te) && isspace(*p->te)) {
-				if (*p->te == '\n')
-					p->line++;
-				p->te++;
-			}
-		}
+		else if (!isspace(*p->te))
+			break;
 
-		else
-			return;
+		while ((p->te != p->fe) && isspace(*p->te)) {
+			if (*p->te == '\n')
+				++p->line;
+			++p->te;
+		}
 
 		p->tb = p->te;
 	}
--- LVM2/WHATS_NEW	2011/03/10 14:40:33	1.1943
+++ LVM2/WHATS_NEW	2011/03/10 14:51:35	1.1944
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Optimise _get_token() and _eat_space().
   Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
   Use hash tables to speedup string search in validate_vg().
   Refactor allocation of VG structure, add alloc_vg().


