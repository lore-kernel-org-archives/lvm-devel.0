From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Mar 2019 11:00:52 -0500
Subject: master - pvscan: ignore online for unused PV
Message-ID: <201903051600.x25G0qTP029372@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0c848d4e4a9b53fa1f9cc7a8330fea6b23c07a8
Commit:        a0c848d4e4a9b53fa1f9cc7a8330fea6b23c07a8
Parent:        07483cc165e210a23627b4b6d5c89f9008c9e950
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 4 14:25:53 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 14:25:53 2019 -0600

pvscan: ignore online for unused PV

If an unused PV comes online, ignore it from
pvscan --cache.
---
 tools/pvscan.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 389aafa..c484531 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -644,6 +644,8 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 	const struct format_type *fmt;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
+	uint32_t ext_version;
+	uint32_t ext_flags;
 	int ret = 0;
 
 	log_debug("pvscan metadata from dev %s", dev_name(dev));
@@ -667,6 +669,14 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
+	ext_version = lvmcache_ext_version(info);
+	ext_flags = lvmcache_ext_flags(info);
+
+	if ((ext_version >= 2) && !(ext_flags & PV_EXT_USED)) {
+		log_print("pvscan[%d] PV %s not used.", getpid(), dev_name(dev));
+		return 1;
+	}
+
 	fmt = lvmcache_fmt(info);
 
 	baton.cmd = cmd;


