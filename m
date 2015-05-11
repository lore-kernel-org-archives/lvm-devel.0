From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 11 May 2015 14:30:43 +0000 (UTC)
Subject: master - vgimport: fall back when lvmetad is not running
Message-ID: <20150511143043.58100611BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d748b3455d25192d68e166d89d1c6f67ac226d44
Commit:        d748b3455d25192d68e166d89d1c6f67ac226d44
Parent:        3eb2d4d2ce3c660fb5bd99c2093a00cb8f2fa4d5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 11 09:28:47 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 11 09:28:47 2015 -0500

vgimport: fall back when lvmetad is not running

If lvmetad is configured, but not running,
vgimport would not fall back and run without
lvmetad, but would report an error about
requiring lvmetad.
---
 tools/vgimport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgimport.c b/tools/vgimport.c
index b416e21..b64a7a3 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -91,7 +91,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 	 * We need to reread it to see that it's been exported before we can
 	 * import it.
 	 */
-	if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
+	if (lvmetad_active() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
 		log_error("Failed to scan devices.");
 		return ECMD_FAILED;
 	}


