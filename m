From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:37 +0000 (UTC)
Subject: master - pvscan: fix errors for single dev scan while lvmetad is disabled
Message-ID: <20160506140037.B256E60D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1dbd54885844a934e17f69691d2371a15453033
Commit:        a1dbd54885844a934e17f69691d2371a15453033
Parent:        08aeea6a126d71843a2c133b15565d8efb664ae2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 27 15:06:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 08:59:59 2016 -0500

pvscan: fix errors for single dev scan while lvmetad is disabled

While lvmetad was disabled, 'pvscan --cache dev' would produce
confusing error messages.
---
 tools/pvscan.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index d93773a..50753fd 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -257,6 +257,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	int ret = ECMD_PROCESSED;
 	struct device *dev;
 	const char *pv_name;
+	const char *reason = NULL;
 	int32_t major = -1;
 	int32_t minor = -1;
 	int devno_args = 0;
@@ -309,6 +310,18 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/*
+	 * When lvmetad is disabled, all devices need to be rescanned,
+	 * i.e. the !argc case above, pvscan --cache.
+	 */
+	if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+		log_warn("WARNING: Not using lvmetad because %s.", reason);
+		log_warn("WARNING: Rescan all devices to update lvmetad cache (pvscan --cache).");
+		log_error("Failed to update cache.");
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	/*
 	 * FIXME: when specific devs are named, we generally don't
 	 * want to scan any other devs, but if lvmetad is not yet
 	 * populated, the first 'pvscan --cache dev' does need to


