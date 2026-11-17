Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=160.101.131.9
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794935289;
	b=kXeEgOcjba1OgcXa7MNwbdPnKu4hPZr3MS6MB1ydwU0218OQYoxPJU8biOYAvL6v1cMe
	 fyxxdTb7ACBajAFBX/xiW4HZ5Dhd1JR52FcA9eGcXMTV455sug17OV6ZYErOFbZymFjs4
	 zS/aLSUviCbg1N30r2HgbX1UNyl6NS9a+6O6uaS6vB+x6p2PMg3rmSD7HxRhqHZwLX58x
	 c55NkE8ZOCroRjxS3AQYx4XrUINPsXJOlfwv8FbwCAb9CN3dnRtyQb3ERgb1Zdj8+Q9B9
	 jjLbE9I11rVwXscCMxmGU1KYWYmaEc0+DzD8oAJTAXZQVaHUSwS3BsPxwndMHSUwHHg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794935289;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=clkDYxOYUV2//VWBBf9hv6Fna6Pdo8oCqJNBvtGuZeg=;
	b=r2VYDP0+evIs8mevWsiT3CCpHoRl+NaffQAywpeRbQUkXd3aW83AIQ0xnQ9ZIznE1Ks3
	 gbMh0Btu/yQ0LX6iBd7YvPWaGhj7N68zn8oT22RdAhQahWAPny0tTlUXq+o6A+sIYicNM
	 q0cS+1T7ChHclUPWW2Xf86wNc0K2gmbMUsoncFyrIWiurDflnMmu2bhVNrm0xu6CH0ETG
	 G6HFf3b8lb1EXxpwiTCVy3YghWrdhIlhwyg/18ZFSSXqUGUgPWTt+FHGA8Svh83v1392L
	 oOIqBcEL5/8d94iDR3fchnABFTV+tb+W9yqjoFNY3cOobVAkSdrCkcVDwMgk/CCdT8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=citrix.com;
	spf=pass smtp.mailfrom=citrix.com;
	arc=none smtp.remote-ip=160.101.131.9
Received: from na1pdmzitismtp02.tibco.com (unknown [160.101.131.9])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B02C606A32C
	for <lvm-devel@lists.linux.dev>; Tue, 17 Nov 2026 17:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4B02C606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=citrix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=citrix.com
Received: from mewpvdipd1070.citrite.net (unknown [10.113.40.46])
	by na1pdmzitismtp02.tibco.com (Postfix) with ESMTP id 1F20884BB383;
	Tue, 17 Nov 2026 12:06:36 -0500 (EST)
From: Mark Syms <mark.syms@citrix.com>
To: lvm-devel@lists.linux.dev
Cc: zkabelac@redhat.com,
	teigland@redhat.com,
	Mark Syms <mark.syms@citrix.com>
Subject: [PATCH] activate: skip multipath devices with no active path that queue I/O
Date: Tue, 17 Nov 2026 17:08:00 +0000
Message-ID: <20261117170800.1199104-1-mark.syms@citrix.com>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Reading a multipath device that has lost every path while its table
still has queue_if_no_path blocks until a path returns. When the LUN
has been unmapped or removed on the array, that is never, and every
command that scans devices hangs in D state on it, whichever VG it was
run for. Nothing in the scan avoided such a device: dm_device_is_usable()
carried a FIXME for exactly this case.

Seen in production with a NetApp LUN unmapped while still in use, under
the shipped "no_path_retry queue" config: every vgs/lvs on every host
that saw the LUN hung, along with everything that serialised behind them.

Treat such a device as unusable, alongside the existing check for
mirrors that would block. The status gives each path's state; the table
says whether the device queues. Both come from device-mapper ioctls, so
the check does no I/O to the device itself. A device whose paths have
all been removed is treated the same way.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Signed-off-by: Mark Syms <mark.syms@citrix.com>
---
Tested on XenServer 8, whose lvm2 is 2.02.180-based, with the same
change in device_is_usable(): with every path to a NetApp FC LUN failed
under no_path_retry queue, an lvs of an unrelated VG with no device
restriction completed in about a second, where without the change it
blocked until the map stopped queueing (17 minutes in that run). It builds cleanly
on main; I have not added a test/shell case, as faking a dead queueing
multipath map needs real dm-multipath paths.

 WHATS_NEW                  |  1 +
 lib/activate/activate.h    |  1 +
 lib/activate/dev_manager.c | 62 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 63 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 095ecff..c511d05 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.45 - 
 ==================
+  Skip multipath devices that queue I/O with no active path when scanning.
   Warn that extending a RAID LV before dm-raid 1.15.0 needs a resync.
   Refuse extending a RAID LV that is degraded or rebuilding a leg.
   Add configure --with-default-io-engine=ENGINE setting.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ef2e1b2..0049fec 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -280,6 +280,7 @@ void fs_unlock(void);
 #define TARGET_NAME_ERROR_OLD "erro"	/* Truncated in older kernels */
 #define TARGET_NAME_LINEAR "linear"
 #define TARGET_NAME_MIRROR "mirror"
+#define TARGET_NAME_MULTIPATH "multipath"
 #define TARGET_NAME_RAID "raid"
 #define TARGET_NAME_SNAPSHOT "snapshot"
 #define TARGET_NAME_SNAPSHOT_MERGE "snapshot-merge"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ad3fb10..e0f63bb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -843,6 +843,57 @@ static int _is_usable_uuid(const struct device *dev, const char *name, const cha
 	return 1;
 }
 
+/* Path entries in multipath status are "<major>:<minor> <A|F> ..." */
+static int _multipath_has_active_path(const char *status)
+{
+	unsigned major, minor;
+	char state;
+	const char *p = status;
+
+	while (p && *p) {
+		if (sscanf(p, "%u:%u %c", &major, &minor, &state) == 3 && state == 'A')
+			return 1;
+		if ((p = strchr(p, ' ')))
+			p++;
+	}
+
+	return 0;
+}
+
+/*
+ * Reading a multipath device with no active path that queues I/O blocks
+ * until a path returns, which for a LUN removed from the array is never.
+ */
+static int _ignore_pathless_queueing_multipath(struct device *dev,
+					       const char *status)
+{
+	struct dm_task *dmt;
+	uint64_t s, l;
+	char *target_type = NULL, *params;
+	void *next = NULL;
+	int queueing = 0;
+
+	if (_multipath_has_active_path(status))
+		return 0;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, NULL, NULL, NULL, NULL,
+				    MAJOR(dev->dev), MINOR(dev->dev), 0, 1, 0)))
+		return_0;
+
+	do {
+		next = dm_get_next_target(dmt, next, &s, &l,
+					  &target_type, &params);
+		if (target_type && params &&
+		    !strcmp(target_type, TARGET_NAME_MULTIPATH) &&
+		    strstr(params, "queue_if_no_path"))
+			queueing = 1;
+	} while (next);
+
+	dm_task_destroy(dmt);
+
+	return queueing;
+}
+
 /*
  * dm_device_is_usable
  * @dev
@@ -856,6 +907,7 @@ static int _is_usable_uuid(const struct device *dev, const char *name, const cha
  *        b) it is a snapshot origin
  *     4) an error target
  *     5) the LV name is a reserved name.
+ *     6) a multipath device with no active path that queues I/O
  *
  * Returns: 1 if usable, 0 otherwise
  */
@@ -902,7 +954,6 @@ int dm_device_is_usable(struct cmd_context *cmd, struct device *dev, struct dev_
 	    !_is_usable_uuid(dev, name, uuid, check.check_reserved, check.check_lv, is_lv))
 		goto out;
 
-	/* FIXME Also check for mpath no paths */
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
@@ -910,6 +961,15 @@ int dm_device_is_usable(struct cmd_context *cmd, struct device *dev, struct dev_
 		if (!target_type)
 			continue;
 
+		if (check.check_blocked && params &&
+		    !strcmp(target_type, TARGET_NAME_MULTIPATH) &&
+		    _ignore_pathless_queueing_multipath(dev, params)) {
+			log_debug_activation("%s: Multipath device %s has no active path "
+					     "and queues I/O, not usable.",
+					     dev_name(dev), name);
+			goto out;
+		}
+
 		if (check.check_blocked && !strcmp(target_type, TARGET_NAME_MIRROR)) {
 			if (ignore_lvm_mirrors()) {
 				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
-- 
2.56.0

