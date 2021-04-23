From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:49 +0000 (GMT)
Subject: main - cov: check setup_devices return code
Message-ID: <20210423210549.61071393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d95b26fae0bdab7d306f0dff1d9328a697e041f3
Commit:        d95b26fae0bdab7d306f0dff1d9328a697e041f3
Parent:        ece80cd0fbce92d2ce248913fceffbf15e9d37f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:34:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: check setup_devices return code

---
 tools/pvck.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 6bc1c091f..74663ec43 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3187,8 +3187,8 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 	if (argc == 1)
 		setup_device(cmd, argv[0]);
-	else
-		setup_devices(cmd);
+	else if (!setup_devices(cmd))
+		return ECMD_FAILED;
 
 	for (i = 0; i < argc; i++) {
 		pv_name = argv[i];


