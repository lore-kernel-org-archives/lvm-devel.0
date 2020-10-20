From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:06 +0000 (GMT)
Subject: stable-2.02 - man: more precise UNIT
Message-ID: <20201020212506.7D699385DC37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50621533ddb143a41d2dd5f1bd85f8d45c6581fe
Commit:        50621533ddb143a41d2dd5f1bd85f8d45c6581fe
Parent:        8af590b1bbb5796d20c32d41b6e4dcb7d2441fb9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 12:32:46 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:41:34 2020 +0200

man: more precise UNIT

Since 'kilobytes' could be seen in 2 way - SI as '1000',
while all programmers sees it as '1024' - switch to
commonly acceptted  KiB, MiB....

Resolves RHBZ 1496255.
---
 tools/command.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index acb79c9c1..fcb833fa2 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3233,9 +3233,8 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
 	       "The default input unit is specified by letter, followed by |UNIT.\n"
 	       "UNIT represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
-	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,\n"
-	       "m|M is megabytes, g|G is gigabytes, t|T is terabytes,\n"
-	       "p|P is petabytes, e|E is exabytes.\n"
+	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,\n"
+	       "m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.\n"
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 


