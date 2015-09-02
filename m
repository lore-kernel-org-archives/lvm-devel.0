From: okozina <okozina@fedoraproject.org>
Date: Wed,  2 Sep 2015 15:27:44 +0000 (UTC)
Subject: master - pvmove: skip polling later in test mode
Message-ID: <20150902152744.90D8660554@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9d954cb3cf974563d27ef1594d924c4de9c5eb9
Commit:        a9d954cb3cf974563d27ef1594d924c4de9c5eb9
Parent:        6e4f2da9b327e00fb7bef89dffc3b56225b0cde7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Sep 2 16:54:22 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Sep 2 17:25:37 2015 +0200

pvmove: skip polling later in test mode

---
 tools/pvmove.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0e31764..d6403ad 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -817,9 +817,6 @@ int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 	int r;
 	struct poll_operation_id *id = NULL;
 
-	if (test_mode())
-		return ECMD_PROCESSED;
-
 	if (uuid) {
 		id = _create_id(cmd, pv_name, vg_name, lv_name, uuid);
 		if (!id) {
@@ -828,7 +825,10 @@ int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		}
 	}
 
-	r = poll_daemon(cmd, background, PVMOVE, &_pvmove_fns, "Moved", id);
+	if (test_mode())
+		r = ECMD_PROCESSED;
+	else
+		r = poll_daemon(cmd, background, PVMOVE, &_pvmove_fns, "Moved", id);
 
 	_destroy_id(cmd, id);
 


