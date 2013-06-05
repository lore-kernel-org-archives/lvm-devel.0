From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:29 +0000 (UTC)
Subject: dev-mornfall-lvmcache - args: do not accept >=16EiB sizes
Message-ID: <20130605120429.5B6CC60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99f04835802ee675242a4896697eb784717ee998
Commit:        99f04835802ee675242a4896697eb784717ee998
Parent:        c5c452a137ba36840d71f3bde23b1a6b496ede4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 14:50:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:23:51 2013 +0200

args: do not accept >=16EiB sizes

Instead of seeing wierd overflows inside the lvm code,
giving false error messages, kill the user experiment in the begining.

Who needs to use more then 16EiB with lvm2 and 64bit anyway...
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f5adc0b..86357fd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not accept size parameters bigger then 16EiB.
   Fix release of PV's fid in free_pv_fid().
   Skip monitoring of snapshots that are already bigger then origin.
   Add lv_is_cow_covering_origin() to check if cow covers origin size.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0b64ed8..89ead2c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -340,6 +340,10 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 	} else
 		v *= factor;
 
+	if ((uint64_t) v >= (UINT64_MAX >> SECTOR_SHIFT)) {
+		log_error("Size is too big (>=16EiB).");
+		return 0;
+	}
 	av->i_value = (int32_t) v;
 	av->ui_value = (uint32_t) v;
 	av->i64_value = (int64_t) v;


