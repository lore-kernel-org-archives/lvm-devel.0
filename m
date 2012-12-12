From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 12 Dec 2012 13:45:01 +0000 (UTC)
Subject: master - toollib: Avoid a global lock in process_each_pv if lvmetad is used.
Message-ID: <20121212134502.055D7A0C3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b19f840af82cf176a26c8bddc2217fe862087794
Commit:        b19f840af82cf176a26c8bddc2217fe862087794
Parent:        e5709a32be746ad0d21b13df18f23387bcccabef
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Dec 12 14:39:52 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Dec 12 14:44:03 2012 +0100

toollib: Avoid a global lock in process_each_pv if lvmetad is used.

The motivation to grab the global lock is to avoid a scan and metadata parsing
for each PV, but the cost of obtaining metadata is _mostly_ mitigated by having
lvmetad around. Not taking the global lock improves throughput when multiple pvs
or related commands are running in parallel, like in RHEV.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 817580f..1d67e5d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -701,7 +701,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE);
+	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;


