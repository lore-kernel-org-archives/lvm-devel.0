From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:08 +0000 (UTC)
Subject: master - debug: put stack on error path
Message-ID: <20151113101908.CC325610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=112c0592ad0d25bae0cea04275d201d72187f85b
Commit:        112c0592ad0d25bae0cea04275d201d72187f85b
Parent:        007be91e3d128320c290fc404532d1d691212b88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:04:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

debug: put stack on error path

At least check result and trace it.
However we may need better error reaction in this case.
---
 lib/cache/lvmetad.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7ef1c8c..f8393df 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1734,7 +1734,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 * Update the local lvmetad cache so it correctly reflects any
 	 * changes made on remote hosts.
 	 */
-	lvmetad_pvscan_all_devs(cmd, NULL);
+	if (!lvmetad_pvscan_all_devs(cmd, NULL))
+		stack; /* FIXME: Anything more on this error path ? */
 
 	/*
 	 * Clear the global_invalid flag in lvmetad.


