From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 12 Feb 2017 16:30:44 +0000 (UTC)
Subject: master - cleanup: drop double const specifier
Message-ID: <20170212163044.BF3FA60EC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=375e38709ca2842c97ee56899a8a3f34abc61a30
Commit:        375e38709ca2842c97ee56899a8a3f34abc61a30
Parent:        2a9eda1229c9d5d7150acdd3d8dd4908fbc784a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 20:30:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 11 20:30:16 2017 +0100

cleanup: drop double const specifier

Remove duplicated 'const' specifier.
Reindent.
---
 daemons/lvmpolld/lvmpolld-cmd-utils.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
index f70fd0d..601338f 100644
--- a/daemons/lvmpolld/lvmpolld-cmd-utils.c
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -19,10 +19,12 @@
 
 #define MIN_ARGV_SIZE  8
 
-static const char *const const polling_ops[] = { [PVMOVE] = LVMPD_REQ_PVMOVE,
-						 [CONVERT] = LVMPD_REQ_CONVERT,
-						 [MERGE] = LVMPD_REQ_MERGE,
-						 [MERGE_THIN] = LVMPD_REQ_MERGE_THIN };
+static const char *const polling_ops[] = {
+	[PVMOVE] = LVMPD_REQ_PVMOVE,
+	[CONVERT] = LVMPD_REQ_CONVERT,
+	[MERGE] = LVMPD_REQ_MERGE,
+	[MERGE_THIN] = LVMPD_REQ_MERGE_THIN
+};
 
 const char *polling_op(enum poll_type type)
 {


