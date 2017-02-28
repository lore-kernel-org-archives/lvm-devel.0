From: David Teigland <teigland@sourceware.org>
Date: Tue, 28 Feb 2017 14:49:24 -0500
Subject: master - man: fix syntax for PV ranges
Message-ID: <201702281949.v1SJnOHO011015@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89661981e829d2cb228e3db6f8127d14526ea025
Commit:        89661981e829d2cb228e3db6f8127d14526ea025
Parent:        4a14617dc4413911b3af0cfea38cd5c2fe45afa8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 28 12:22:12 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 28 12:22:12 2017 -0600

man: fix syntax for PV ranges

---
 tools/command.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 59818f9..a8c38ba 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2733,8 +2733,8 @@ void print_man_all_positions_desc(struct command_name *cname)
 		printf("Physical Volume name, a device path under /dev.\n"
 		       "For commands managing physical extents, a PV positional arg\n"
 		       "generally accepts a suffix indicating a range of physical extents.\n"
-		       "Start and end range (inclusive): \\fIPV\\fP[:\\fIPE\\fP[-\\fIPE\\fP].\n"
-		       "Start and length range (counting from 0): \\fIPV\\fP[:\\fIPE\\fP[+\\fIPE\\fP].\n");
+		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP[\\fB-\\fP\\fIPE\\fP]].\n"
+		       "Start and length range (counting from 0): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP[\\fB+\\fP\\fIPE\\fP]].\n");
 	}
 
 	if (has_tag_val) {


