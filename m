From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:28 +0000 (GMT)
Subject: master - man: more precise UNIT
Message-ID: <20201023234328.9C258384A881@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=413c88116dd1a2a922216fd640598812b93ae3c9
Commit:        413c88116dd1a2a922216fd640598812b93ae3c9
Parent:        9740e98cbdba114457dc20bf43ad4c4b8994876f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 12:32:46 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

man: more precise UNIT

Since 'kilobytes' could be seen in 2 way - SI as '1000',
while all programmers sees it as '1024' - switch to
commonly acceptted  KiB, MiB....

Resolves RHBZ 1496255.
---
 tools/command.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 4fc55e2be..dd1f94194 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3292,9 +3292,8 @@ static void _print_man_all_positions_desc(struct command_name *cname)
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
 


