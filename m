From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 07:53:59 +0000 (UTC)
Subject: master - activation: change log_error to log_warn if refresh before autoactivation fails
Message-ID: <20131127075359.9BB6160DBA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=120df5561088f4a5277716117339d9212b666214
Commit:        120df5561088f4a5277716117339d9212b666214
Parent:        d6e67b850365864bba91619a40503ff0b0392e2c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 08:53:26 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 08:53:26 2013 +0100

activation: change log_error to log_warn if refresh before autoactivation fails

---
 tools/pvscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 981a9c2..4f99f45 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -148,7 +148,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	}
 
 	if (!refresh_done)
-		log_error("%s: refresh before autoactivation failed.", vg->name);
+		log_warn("%s: refresh before autoactivation failed.", vg->name);
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);


