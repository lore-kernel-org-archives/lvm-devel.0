From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Nov 2014 14:19:43 +0000 (UTC)
Subject: master - pvresize: fix size in 'Resizing to ...' verbose message to show proper result size
Message-ID: <20141125141943.444E560E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62f3a4d2d88576ac160f7a7a5f5dc7608c7a1c04
Commit:        62f3a4d2d88576ac160f7a7a5f5dc7608c7a1c04
Parent:        cd3b6070aab5b50ab60f8434ca6efd3736e927be
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 25 15:16:09 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 25 15:19:10 2014 +0100

pvresize: fix size in 'Resizing to ...' verbose message to show proper result size

---
 WHATS_NEW               |    1 +
 lib/metadata/pv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a19cdb9..f655f24 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Fix size in pvresize "Resizing to ..." verbose msg to show proper result size.
 
 Version 2.02.113 - 24th November 2014
 =====================================
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 00a7fd5..6499e36 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -650,7 +650,7 @@ int pv_resize_single(struct cmd_context *cmd,
 	}
 
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, pv_size(pv));
+		    pv_name, size);
 
 	if (!pv_resize(pv, vg, size))
 		goto_out;


