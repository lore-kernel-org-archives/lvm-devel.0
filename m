From: okozina <okozina@fedoraproject.org>
Date: Thu, 21 May 2015 09:26:32 +0000 (UTC)
Subject: master - lvmpolld-client.c: debug print when querying progress
Message-ID: <20150521092632.578DA60D70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d998aa13df81e5cec339c86a63dac934de3da35
Commit:        6d998aa13df81e5cec339c86a63dac934de3da35
Parent:        01b06cb71b25111c9d0ddaccca97e788f2dedf9d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 21 11:10:09 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Thu May 21 11:20:21 2015 +0200

lvmpolld-client.c: debug print when querying progress

---
 lib/lvmpolld/lvmpolld-client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 58bc86f..d770e74 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -330,6 +330,8 @@ int lvmpolld_request_info(const struct poll_operation_id *id, const struct daemo
 		return 0;
 	}
 
+	log_debug_lvmpolld("Asking lvmpolld for progress status of an operation on %s/%s.",
+			   id->vg_name, id->lv_name);
 	info = _request_progress_info(id->uuid, parms->aborting);
 	*finished = info.finished;
 


