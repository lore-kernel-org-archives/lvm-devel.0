From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:58 +0000 (UTC)
Subject: master - cov: add internal error for impossible code path
Message-ID: <20161211223458.0C7C36038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8c729efd094146437c3ed5b336b929608401535
Commit:        b8c729efd094146437c3ed5b336b929608401535
Parent:        794093722c657780171486dbfd8cd0ec392e4019
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 22:55:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

cov: add internal error for impossible code path

---
 tools/vgchange.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 910f33a..455f688 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -533,6 +533,11 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 	struct logical_volume *lv;
 	int lv_lock_count = 0;
 
+	if (!lock_type) {
+		log_error(INTERNAL_ERROR "No locktype_ARG.");
+		return 0;
+	}
+
 	/*
 	 * This is a special/forced exception to change the lock type to none.
 	 * It's needed for recovery cases and skips the normal steps of undoing


