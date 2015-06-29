From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 13:24:16 +0000 (UTC)
Subject: master - lv: time: increase buffer to 4k in lv_time_dup
Message-ID: <20150629132417.033C9614A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=621398ebb79760d6e86f8264e4198946d59e6522
Commit:        621398ebb79760d6e86f8264e4198946d59e6522
Parent:        158723608911fae1f18df5ea3c506434b521b5b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 29 15:24:00 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 15:24:00 2015 +0200

lv: time: increase buffer to 4k in lv_time_dup

---
 lib/metadata/lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 2a87edd..f0a3d77 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -875,7 +875,7 @@ int lv_set_creation(struct logical_volume *lv,
 
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode)
 {
-	char buffer[50];
+	char buffer[4096];
 	struct tm *local_tm;
 	time_t ts = (time_t)lv->timestamp;
 	const char *format = iso_mode ? DEFAULT_TIME_FORMAT : lv->vg->cmd->time_format;


