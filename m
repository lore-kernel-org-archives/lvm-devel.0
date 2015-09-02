From: okozina <okozina@fedoraproject.org>
Date: Wed,  2 Sep 2015 15:27:42 +0000 (UTC)
Subject: master - lvconvert: skip polling in test mode
Message-ID: <20150902152742.776FA61045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e4f2da9b327e00fb7bef89dffc3b56225b0cde7
Commit:        6e4f2da9b327e00fb7bef89dffc3b56225b0cde7
Parent:        ab5df4bc5c568bc8c49fadfc0d1998ff1a4dbcb1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Sep 2 16:53:23 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Sep 2 17:25:29 2015 +0200

lvconvert: skip polling in test mode

---
 tools/lvconvert.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 07d9f43..2bffb07 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -763,6 +763,9 @@ static int _lvconvert_poll_by_id(struct cmd_context *cmd, struct poll_operation_
 				 int is_merging_origin,
 				 int is_merging_origin_thin)
 {
+	if (test_mode())
+		return ECMD_PROCESSED;
+
 	if (is_merging_origin)
 		return poll_daemon(cmd, background,
 				(MERGING | (is_merging_origin_thin ? THIN_VOLUME : SNAPSHOT)),


