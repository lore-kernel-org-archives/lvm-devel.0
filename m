From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 12:16:24 -0500
Subject: master - man/help: improve the PV range description
Message-ID: <201703031716.v23HGOnh019908@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7ee89d80b0b876cd73573338022b1308d59b209
Commit:        e7ee89d80b0b876cd73573338022b1308d59b209
Parent:        2a5e24580abbb103cddc4ec24fe9423e11be5e64
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 11:07:49 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 11:15:27 2017 -0600

man/help: improve the PV range description

---
 tools/command.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 25be87f..7f6bd2b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1848,10 +1848,12 @@ void print_usage_notes(struct command_name *cname, struct command *cmd)
 
 	printf("        PV\n"
 	       "        Physical Volume name, a device path under /dev.\n"
-	       "        For commands managing physical extents, a PV positional\n"
-	       "        arg generally accepts a suffix indicating a range of PEs:\n"
-	       "        PV[:PE[-PE]] is start and end range (inclusive),\n"
-	       "        PV[:PE[+PE]] is start and length range (counting from 0).\n");
+	       "        For commands managing physical extents, a PV positional arg\n"
+	       "        generally accepts a suffix indicating a range (or multiple ranges)\n"
+	       "        of PEs. When the first PE is omitted, it defaults to the start of\n"
+	       "        the device, and when the last PE is omitted it defaults to the end.\n"
+	       "        PV[:PE-PE]... is start and end range (inclusive),\n"
+	       "        PV[:PE+PE]... is start and length range (counting from 0).\n");
 	printf("\n");
 
 	printf("        LV\n"
@@ -2882,9 +2884,11 @@ void print_man_all_positions_desc(struct command_name *cname)
 		printf(".br\n");
 		printf("Physical Volume name, a device path under /dev.\n"
 		       "For commands managing physical extents, a PV positional arg\n"
-		       "generally accepts a suffix indicating a range of physical extents.\n"
-		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP[\\fB-\\fP\\fIPE\\fP]].\n"
-		       "Start and length range (counting from 0): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP[\\fB+\\fP\\fIPE\\fP]].\n");
+		       "generally accepts a suffix indicating a range (or multiple ranges)\n"
+		       "of physical extents (PEs). When the first PE is omitted, it defaults\n"
+		       "to the start of the device, and when the last PE is omitted it defaults to end.\n"
+		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB-\\fP\\fIPE\\fP]...\n"
+		       "Start and length range (counting from 0): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB+\\fP\\fIPE\\fP]...\n");
 	}
 
 	if (has_tag_val) {


