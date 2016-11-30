From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 22:48:41 +0000 (UTC)
Subject: master - WHATS_NEW: New argument --blackboxsize
Message-ID: <20161130224841.4C9AA607A1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0a508cfab66049e3953c7cf14c159170a585088
Commit:        c0a508cfab66049e3953c7cf14c159170a585088
Parent:        5da10fda4c0b7caa0e9cd221298a8ad475332e36
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 16:40:49 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 16:47:31 2016 -0600

WHATS_NEW: New argument --blackboxsize

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 20f3296..c35a85b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  lvmdbusd --blackboxsize <n> added, used to override default size of 16
   Allow a transiently failed RaidLV to be refreshed
   Use lv_update_and_reload() inside mirror code where it applies.
   Preserve mirrored status for temporary layered mirrors.


