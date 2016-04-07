From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  7 Apr 2016 00:51:28 +0000 (UTC)
Subject: master - libdm: Correct typo.
Message-ID: <20160407005128.B87666116B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7dcbf1dfd0bc5e2d057d41900f10016d170bdae2
Commit:        7dcbf1dfd0bc5e2d057d41900f10016d170bdae2
Parent:        f19ec0e36d64bcde6cb4cbd00376fe2377e81b19
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 7 01:51:09 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 7 01:51:09 2016 +0100

libdm: Correct typo.

---
 libdm/ioctl/libdm-iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 8259a78..2733b86 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1830,7 +1830,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->read_only ? "readonly " : "",
 			     dmt->skip_lockfs ? "skiplockfs " : "",
 			     dmt->retry_remove ? "retryremove " : "",
-			     dmt->deferred_remove ? "defferedremove " : "",
+			     dmt->deferred_remove ? "deferredremove " : "",
 			     dmt->secure_data ? "securedata " : "",
 			     dmt->query_inactive_table ? "inactive " : "",
 			     dmt->enable_checks ? "enablechecks " : "",


