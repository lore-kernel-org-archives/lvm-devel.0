From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:28 +0000 (UTC)
Subject: master - cleanup: make gcc happier with initializers
Message-ID: <20131122200928.1379A60E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62db5c1e48467ef846432652dd1058eb85c0bcbd
Commit:        62db5c1e48467ef846432652dd1058eb85c0bcbd
Parent:        6ebbf1982892a819dc14045a8dca0ad512cebdf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 20:42:03 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:56 2013 +0100

cleanup: make gcc happier with initializers

Whole struct will be set to 0, just
if the first member is array, gcc gives warning
we should initialized this element as array,
so pick any later simple type.
---
 tools/reporter.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index dccd785..bf181e7 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -141,8 +141,8 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
 	struct label *label;
-	struct label _dummy_label = { 0 };
-	struct device _dummy_device = { 0 };
+	struct label _dummy_label = { .dev = 0 };
+	struct device _dummy_device = { .dev = 0 };
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);


