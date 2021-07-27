From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:31 +0000 (GMT)
Subject: main - cov: add internal error for missing arg
Message-ID: <20210727225031.DE07B385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=046d85af3d7a103573e56ef6861dc5d6ded9ecc7
Commit:        046d85af3d7a103573e56ef6861dc5d6ded9ecc7
Parent:        69379df8f35404269e5aa4a275a7686a87076f27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:40:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: add internal error for missing arg

Analyzer is happier.
---
 tools/lvchange.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8293f5035..bfd464d5c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1685,6 +1685,11 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 {
 	const char *msg = arg_str_value(cmd, syncaction_ARG, NULL);
 
+	if (!msg) {
+		log_error(INTERNAL_ERROR "Missing syncaction arg.");
+		return ECMD_FAILED;
+	}
+
 	if (lv_raid_has_integrity(lv) && !strcmp(msg, "repair")) {
 		log_error("Use syncaction check to detect and correct integrity checksum mismatches.");
 		return ECMD_FAILED;


