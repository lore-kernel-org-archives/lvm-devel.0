From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:59 +0000 (GMT)
Subject: main - cov: pvck validates setup_device return value
Message-ID: <20210920132959.ADA593858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6427803252354203dfa5d816c6a8dc0ae385051e
Commit:        6427803252354203dfa5d816c6a8dc0ae385051e
Parent:        b6e9892bc6ae23406847a20236c7c954792468e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:33:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:18:13 2021 +0200

cov: pvck validates setup_device return value

---
 tools/pvck.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 49bcb5fd3..629e1feee 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3178,9 +3178,10 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	 * but this is here to preserve the historical output.
 	 */
 
-	if (argc == 1)
-		setup_device(cmd, argv[0]);
-	else if (!setup_devices(cmd))
+	if (argc == 1) {
+		if (!setup_device(cmd, argv[0]))
+			return_ECMD_FAILED;
+	} else if (!setup_devices(cmd))
 		return_ECMD_FAILED;
 
 	for (i = 0; i < argc; i++) {


