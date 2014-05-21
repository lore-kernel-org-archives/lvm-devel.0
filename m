From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:05 +0000 (UTC)
Subject: master - cleanup: make error message more readable
Message-ID: <20140521225605.C53DE609E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4ac21aded0eec0e93ce0026cb77cd377d8713ef
Commit:        a4ac21aded0eec0e93ce0026cb77cd377d8713ef
Parent:        aafd7c878c2a4bdcb72182bd31e52bae280898d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:10:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:41 2014 +0200

cleanup: make error message more readable

---
 tools/pvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index f87cd8c..afa6829 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -177,7 +177,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_count(cmd, all_ARG) && argc) {
-		log_error("Option a and PhysicalVolumePath are exclusive");
+		log_error("Option --all and PhysicalVolumePath are exclusive.");
 		return EINVALID_CMD_LINE;
 	}
 


