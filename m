From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 Aug 2013 06:32:13 +0000 (UTC)
Subject: master - dumpconfig: also mention profilable type if giving hint about known types
Message-ID: <20130819063213.1AE8D61358@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99fd710cfd8beb88eb860e16007209d0acb1c440
Commit:        99fd710cfd8beb88eb860e16007209d0acb1c440
Parent:        d8b781e8ab9be0e54fa68834398bc42ce9465ba0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 19 08:32:03 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 19 08:32:03 2013 +0200

dumpconfig: also mention profilable type if giving hint about known types

---
 tools/dumpconfig.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 0887297..18fba34 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -188,7 +188,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	}
 	else {
 		log_error("Incorrect type of configuration specified. "
-			  "Expected one of: current, default, missing, new.");
+			  "Expected one of: current, default, missing, new, profilable.");
 		r = EINVALID_CMD_LINE;
 		goto out;
 	}


