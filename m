From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Feb 2017 21:14:59 +0000 (UTC)
Subject: master - man: add ENVIRONMENT VARIABLES section
Message-ID: <20170224211459.DC07160FC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f6bdf707db24e882b3c3f86f8a5f2e2d2007c98
Commit:        5f6bdf707db24e882b3c3f86f8a5f2e2d2007c98
Parent:        84cceaf9b9f0f323c78e9818c2b54c97d71b392f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 24 15:05:17 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 24 15:05:17 2017 -0600

man: add ENVIRONMENT VARIABLES section

---
 tools/command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 4e7c009..5dd0298 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2825,8 +2825,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
-	printf("\n.HP\n");
-	printf("Environment");
+	printf(".SH ENVIRONMENT VARIABLES");
 	printf("\n");
 	printf(".br\n");
 	printf("See \\fBlvm\\fP(8) for information about environment variables used by lvm.\n"


