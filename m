From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 20:53:53 +0000 (UTC)
Subject: master - pvmove: Accept PE ranges as start+length.
Message-ID: <20130923205353.90345614DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7233e584adeadd1186eb8cb26d45d65c1f446725
Commit:        7233e584adeadd1186eb8cb26d45d65c1f446725
Parent:        bbcc120e5a2c781dc372c4d7329a262247f68f98
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 23 19:50:34 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 23 19:50:34 2013 +0100

pvmove: Accept PE ranges as start+length.

---
 WHATS_NEW       |    1 +
 man/pvmove.8.in |    7 +++++++
 tools/toollib.c |   11 ++++++++++-
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8c1a343..4ffbe4f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Support start+length notation with command line PE ranges.
   Exit cleanly with message when pvmove cannot restart because LV is inactive.
 
 Version 2.02.102 - 23rd September 2013
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index 79ccf1c..c77dcbc 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -123,6 +123,13 @@ inclusive on /dev/sdb1 - like this:
 .sp
 .B pvmove /dev/sdb1:1000-1999
 .P
+A range can also be specified as start+length, so
+.sp
+.B pvmove /dev/sdb1:1000+1000
+.P
+also refers to 1000 Physical Extents starting from Physical Extent number 1000.
+(Counting starts from 0, so this refers to the 1001st to the 2000th inclusive.)
+.P
 To move a range of Physical Extents to a specific location (which must have
 sufficent free extents) use the form:
 .sp
diff --git a/tools/toollib.c b/tools/toollib.c
index 83789df..099e82b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1081,7 +1081,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 		      const char *pvname, uint32_t size)
 {
 	char *endptr;
-	uint32_t start, end;
+	uint32_t start, end, len;
 
 	/* Default to whole PV */
 	if (!c) {
@@ -1121,7 +1121,16 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 					goto error;
 				c = endptr;
 			}
+		} else if (*c == '+') {	/* Length? */
+			c++;
+			if (isdigit(*c)) {
+				if (!xstrtouint32(c, &endptr, 10, &len))
+					goto error;
+				c = endptr;
+				end = start + (len ? (len - 1) : 0);
+			}
 		}
+
 		if (*c && *c != ':')
 			goto error;
 


