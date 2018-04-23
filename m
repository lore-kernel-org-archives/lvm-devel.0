From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:53 -0400
Subject: master - liblvm2app: missed the addition of lvmcache_label_scan
Message-ID: <201804231352.w3NDqrms000999@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c42a18d372f314aa51d9d7877342f1d78fd68973
Commit:        c42a18d372f314aa51d9d7877342f1d78fd68973
Parent:        aee27dc7bad5734012885fe9f174def0a3f26771
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 20 12:00:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 12:00:49 2018 -0500

liblvm2app: missed the addition of lvmcache_label_scan

---
 liblvm/lvm_vg.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 0678bdc..616c78f 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -219,6 +219,8 @@ static vg_t _lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		return NULL;
 	}
 
+	lvmcache_label_scan((struct cmd_context *)libh);
+
 	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags, 0);
 	if (vg_read_error(vg)) {
 		/* FIXME: use log_errno either here in inside vg_read */


