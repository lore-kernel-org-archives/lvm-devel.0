From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 19:44:17 +0000 (UTC)
Subject: master - toollib: skip dev prefix from lv names
Message-ID: <20170215194417.A539D60F39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a30f5f9b0a3677af6f32260ee84ec5c2a6c8393
Commit:        4a30f5f9b0a3677af6f32260ee84ec5c2a6c8393
Parent:        286d39ee3c4334e9ce0609d9136dfd6b5d6bf34a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 13:42:35 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 13:42:35 2017 -0600

toollib: skip dev prefix from lv names

_get_arg_lvnames_using_options() was missing skip_dev_dir()
---
 tools/toollib.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index a539878..6e0a4f1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3434,6 +3434,11 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 		return ECMD_PROCESSED;
 	}
 
+	if (*pos_name == '/') {
+		if (!(pos_name = skip_dev_dir(cmd, pos_name, NULL)))
+			return ECMD_FAILED;
+	}
+
 	if ((split = strchr(pos_name, '/'))) {
 		pos_vgname = pos_name;
 		pos_lvname = split + 1;


