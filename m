From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:36:52 +0000 (UTC)
Subject: master - lvmlockd: set default result value
Message-ID: <20160223203652.8B46D60F99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eccc91f9b0ef7387f46cdd93e3f44ab45e0c1ba3
Commit:        eccc91f9b0ef7387f46cdd93e3f44ab45e0c1ba3
Parent:        0236a34224d31a6ad7b48e451183672e907b15d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 23 14:35:40 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 14:35:40 2016 -0600

lvmlockd: set default result value

The default error value should be set indicating
an error.
---
 lib/locking/lvmlockd.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a33544c..e78e2cb 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -142,6 +142,8 @@ static int _lockd_result(daemon_reply reply, int *result, uint32_t *lockd_flags)
 	const char *flags_str = NULL;
 	const char *lock_type = NULL;
 
+	*result = -1;
+
 	if (reply.error) {
 		log_error("lockd_result reply error %d", reply.error);
 		return 0;


