From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 24 Mar 2017 13:33:29 -0400
Subject: master - man-generator: fix buffer length calculation
Message-ID: <201703241733.v2OHXTdK006689@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d823c65d508f95ad3cd491a047ae1953a55a5c3c
Commit:        d823c65d508f95ad3cd491a047ae1953a55a5c3c
Parent:        25c841af00f858c16ebda7baae87cebcfa59b010
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 18:33:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 18:33:03 2017 +0100

man-generator: fix buffer length calculation

---
 tools/command.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 66d5711..4a2b21f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2299,7 +2299,7 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 static const char *_emit_long_opt_name(char *buf, const char *long_opt_name, size_t len)
 {
 	strcpy(buf, "\\-\\-");
-	strncat(buf, long_opt_name + 2, strlen(buf) - 1);
+	strncat(buf, long_opt_name + 2, len - strlen(buf) - 1);
 	return buf;
 }
 


