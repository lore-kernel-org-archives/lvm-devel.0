From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:46 +0000 (GMT)
Subject: main - man-generator: option description indented
Message-ID: <20210412075546.6B68039FCC7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e01ce8e2aeeb08d7f08d99976fa01635d7c3bfa5
Commit:        e01ce8e2aeeb08d7f08d99976fa01635d7c3bfa5
Parent:        441b702362ad6a756551f059d4ca8d62713de6ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 19:53:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man-generator: option description indented

Left indention is needed only for options, but is actually
unwanted for decription itself.
---
 tools/command.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0f31c5138..a81105b96 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3188,10 +3188,10 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		if (opt_names[opt_enum].desc) {
 			printf("\n");
 			printf(".br\n");
+			printf(".ad b\n");
 			_print_man_option_desc(cname, opt_enum);
-		}
-
-		printf(".ad b\n");
+		} else
+			printf(".ad b\n");
 	}
 }
 


