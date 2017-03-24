From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 24 Mar 2017 10:18:48 -0400
Subject: master - man/help: avoid escaping of '-' with --help
Message-ID: <201703241418.v2OEImQs010961@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4046f9bd956fec51769dc9d43afcd899d2c117b4
Commit:        4046f9bd956fec51769dc9d43afcd899d2c117b4
Parent:        e9433a9de9953171033e10bad9cf9689bd978313
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 15:14:21 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 15:14:21 2017 +0100

man/help: avoid escaping of '-' with --help

---
 tools/command.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 58cd17d..66d5711 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1613,7 +1613,8 @@ static void _print_usage_description(struct command *cmd)
 		if (!bi && desc[di] == ' ')
 			continue;
 
-		buf[bi++] = desc[di];
+		if (desc[di] != '\\')
+			buf[bi++] = desc[di];
 
 		if (bi == (MAX_LINE - 1))
 			break;


