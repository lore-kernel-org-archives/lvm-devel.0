From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 15:13:53 -0400
Subject: master - man_generator: release buffer after use
Message-ID: <201706301913.v5UJDrIR030863@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d08b0971f5f2610459343d0ae2a524d272142d2
Commit:        3d08b0971f5f2610459343d0ae2a524d272142d2
Parent:        ad286a32275283f018adabbf96d569d5c1fd065a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 19:36:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 20:39:02 2017 +0200

man_generator: release buffer after use

Although ATM this code has no memory management at all,
it will not make any harm to release some memory,
when it's not needed anymore.
---
 tools/command.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index afd8831..c094f12 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2279,6 +2279,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 			else
 				printf("\\fB%s\\fP", line_argv[i]);
 		}
+		dm_free(line);
 		return;
 	}
 


