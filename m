From: David Teigland <teigland@sourceware.org>
Date: Fri, 28 Apr 2023 18:32:20 +0000 (GMT)
Subject: main - pvck: improve error for write to existing file
Message-ID: <20230428183220.AE89B3858418@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4440b5b495a2d11ff541dd7e7791e2a83c83609
Commit:        c4440b5b495a2d11ff541dd7e7791e2a83c83609
Parent:        6d262eaf640dead7861c1a7716e216b9bcea75e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 28 13:31:39 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 28 13:31:39 2023 -0500

pvck: improve error for write to existing file

---
 tools/pvck.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/pvck.c b/tools/pvck.c
index 879810b76..0998caaf5 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1444,8 +1444,13 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 	int bad = 0;
 
 	if (arg_is_set(cmd, file_ARG)) {
+		struct stat sb;
 		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
 			return 0;
+		if (!stat(tofile, &sb)) {
+			log_error("File already exists.");
+			return 0;
+		}
 	}
 
 	if (set->mda_num)

