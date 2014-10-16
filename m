From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Oct 2014 20:18:00 +0000 (UTC)
Subject: master - toollib: remove unsed variable in process_each_segment_in_pv
Message-ID: <20141016201800.DEF8D60D6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6c294c5d0b989c3a881c8d084291aaf97fa3ac8
Commit:        a6c294c5d0b989c3a881c8d084291aaf97fa3ac8
Parent:        23a38d242bcc1187aa6ef36383311d789d43c82d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 16 15:15:36 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 16 15:16:52 2014 -0500

toollib: remove unsed variable in process_each_segment_in_pv

Was left unused from the last change to this function.
---
 tools/toollib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index eba9a37..f81acca 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -191,7 +191,6 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			       process_single_pvseg_fn_t process_single_pvseg)
 {
 	struct pv_segment *pvseg;
-	struct pv_list *pvl;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct pv_segment _free_pv_segment = { .pv = pv };


