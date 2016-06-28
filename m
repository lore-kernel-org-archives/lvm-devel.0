From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:22 +0000 (UTC)
Subject: master - lvmlockd: fix coverity report
Message-ID: <20160628013322.3945260237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17ad29ebba4ba1a9361cd424ad1f58e89418a986
Commit:        17ad29ebba4ba1a9361cd424ad1f58e89418a986
Parent:        3985b12a2d11d3f4fd3d98090caa8664be594f5c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 27 11:02:07 2016 -0500
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:28:49 2016 +0100

lvmlockd: fix coverity report

---
 daemons/lvmlockd/lvmlockd-core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index f61939a..b561529 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1031,6 +1031,7 @@ retry:
 			log_error("lvmetad_open reconnect error %d", err);
 			memset(&reply, 0, sizeof(reply));
 			reply.error = err;
+			va_end(ap);
 			return reply;
 		} else {
 			log_debug("lvmetad reconnected");


