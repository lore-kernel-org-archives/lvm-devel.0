From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 27 Jun 2016 16:02:57 +0000 (UTC)
Subject: master - lvmlockd: fix coverity report
Message-ID: <20160627160257.A133F60EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20f22a8bc0fa84d9abd09f580b93d53d37c4c361
Commit:        20f22a8bc0fa84d9abd09f580b93d53d37c4c361
Parent:        6c86d942193e35077537753de91970afbcb0acdd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 27 11:02:07 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 27 11:02:07 2016 -0500

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


