From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:46 +0000 (UTC)
Subject: master - cleanup: skip eval of minor when major is true
Message-ID: <20140331100646.DD59060AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f93c9b447b52058526ca8aadedcd3aed78f8f0fe
Commit:        f93c9b447b52058526ca8aadedcd3aed78f8f0fe
Parent:        a33d4355a1e9a08012f348203c0bf673d778c18e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:43:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:05:34 2014 +0200

cleanup: skip eval of minor when major is true

Use normal '||'.
---
 tools/pvscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index ae14878..dff2bb0 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -344,7 +344,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG)) {
+	if (arg_count(cmd, major_ARG) || arg_count(cmd, minor_ARG)) {
 		log_error("--major and --minor are only valid with --cache.");
 		return EINVALID_CMD_LINE;
 	}


