From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:08 +0000 (UTC)
Subject: master - cleanup: simplier code
Message-ID: <20170219234708.DFE6060563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13dd1ca757ab861bcd8f761f60e3c17384ae6326
Commit:        13dd1ca757ab861bcd8f761f60e3c17384ae6326
Parent:        2260c6d1e6c9b6332bf24e4237258e92543ce37f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 18 19:46:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:43:40 2017 +0100

cleanup: simplier code

Already know string is 'lvm-' so use name[3].
---
 tools/command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index f99d025..06dcc77 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2635,8 +2635,7 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 	int i;
 
 	if (!strncmp(name, "lvm-", 4)) {
-		char *space = strchr(lvmname, '-');
-		*space = ' ';
+		name[3] = ' ';
 		name += 4;
 	}
 


