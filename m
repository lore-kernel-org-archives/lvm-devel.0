From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 07:30:57 +0000 (UTC)
Subject: master - activation: continue with autoactivation if refresh fails
Message-ID: <20131127073057.6548260643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=729b104413e11412866a549ef8a6702f56c4acd1
Commit:        729b104413e11412866a549ef8a6702f56c4acd1
Parent:        8d5cff5b9bb217942c009dca49d0bffb51e85004
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 08:20:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 08:20:02 2013 +0100

activation: continue with autoactivation if refresh fails

If the refresh fails for any reason before autoactivation, let's not
make this a stopper for autoactivation itself - just log the error
message if it appears.

The reason is that in some rare situations, we can still hit the
problem with the suspend call to fail (as already described in
commit d8085edf65006a50608edb821b3d30947abaa838, also
https://bugzilla.redhat.com/show_bug.cgi?id=1027314). The refresh
itself is done for only one reason - to refresh any dm tables
for LVs for which the underlying PVs got unplugged/disconnected
and then plugged/connected back (see also
https://bugzilla.redhat.com/show_bug.cgi?id=954061 for more info).
In this case, the major:minor pair is changed and we need to
update dm tables for LVs accordingly.

Now if refresh fails, the error is still logged, but autoactivation
continues.
---
 tools/pvscan.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index ce8c446..981a9c2 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -147,10 +147,8 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 		usleep(REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY);
 	}
 
-	if (!refresh_done) {
+	if (!refresh_done)
 		log_error("%s: refresh before autoactivation failed.", vg->name);
-		goto out;
-	}
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);


