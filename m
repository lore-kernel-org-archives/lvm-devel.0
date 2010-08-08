From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:30 +0200
Subject: [PATCH 18/25] Replicator: read site_params
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <51fde0b716a8e57c78d9cd1c2a065d2b9e6b6440.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Common function for parsing replicator site parameters.
It's used by lvcreate and lvchange commands.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |  103 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tools/toollib.h |    3 ++
 2 files changed, 105 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bdb52d5..6205c2f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1551,3 +1551,104 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 	return _validate_stripe_params(cmd, stripes, stripe_size);
 }
 
+/**
+ * Parse parameters for replicator site
+ *
+ * \param cmd
+ * \param rsite
+ * \param changed
+ */
+int get_replicator_site_params(struct cmd_context *cmd,
+			       struct replicator_site *rsite,
+			       int *changed)
+{
+	struct replicator_site nrsite;
+
+	if (((arg_count(cmd, fallbehindios_ARG) > 0) +
+	     (arg_count(cmd, fallbehindsize_ARG) > 0) +
+	     (arg_count(cmd, fallbehindtimeout_ARG) > 0)) > 1) {
+		log_error("Only one asynchronous parameter can be used.");
+		return 0;
+	}
+
+	if (arg_count(cmd, fallbehindios_ARG)) {
+		nrsite.fall_behind_ios =
+			arg_uint_value(cmd, fallbehindios_ARG,
+				       DEFAULT_REPLICATOR_FALL_BEHIND_IOS);
+
+		if (rsite->fall_behind_ios != nrsite.fall_behind_ios) {
+			rsite->fall_behind_ios = nrsite.fall_behind_ios;
+			rsite->fall_behind_size = 0;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+		}
+	} else if (arg_count(cmd, fallbehindsize_ARG)) {
+		nrsite.fall_behind_size =
+			arg_uint64_value(cmd, fallbehindsize_ARG,
+					 DEFAULT_REPLICATOR_FALL_BEHIND_SIZE);
+
+		if (rsite->fall_behind_size != nrsite.fall_behind_size) {
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_size = nrsite.fall_behind_size;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+		}
+	} else if (arg_count(cmd, fallbehindtimeout_ARG)) {
+		nrsite.fall_behind_timeout =
+			arg_uint_value(cmd, fallbehindtimeout_ARG,
+				       DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT);
+
+		if (rsite->fall_behind_timeout != nrsite.fall_behind_timeout) {
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_size = 0;
+			rsite->fall_behind_timeout = nrsite.fall_behind_timeout;
+			(*changed)++;
+		}
+	}
+
+	nrsite.policy = NUM_DM_REPLICATOR_POLICIES;
+	if (arg_count(cmd, sitepolicy_ARG)) {
+		nrsite.policy = arg_uint_value(cmd, sitepolicy_ARG,
+						DEFAULT_REPLICATOR_SITE_POLICY);
+		if ((nrsite.policy == DM_REPLICATOR_SYNC) &&
+		    !arg_count(cmd, fallbehindios_ARG) &&
+		    !arg_count(cmd, fallbehindsize_ARG) &&
+		    !arg_count(cmd, fallbehindtimeout_ARG) &&
+		    (rsite->fall_behind_ios ||
+		     rsite->fall_behind_size ||
+		     rsite->fall_behind_timeout)) {
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_size = 0;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+			log_debug("Clearing asynchronous parameters synchronous site.");
+		}
+	}
+
+	if (rsite->fall_behind_ios ||
+	    rsite->fall_behind_size ||
+	    rsite->fall_behind_timeout) {
+		if (nrsite.policy == DM_REPLICATOR_SYNC) {
+			log_error("For synchronous site policy all asynchronous "
+				  "parameters must be deleted.");
+			return 0;
+		} else if (nrsite.policy == NUM_DM_REPLICATOR_POLICIES)
+			nrsite.policy = (rsite->policy == DM_REPLICATOR_SYNC) ?
+				DEFAULT_REPLICATOR_SITE_POLICY : rsite->policy;
+	} else {
+		if (nrsite.policy != NUM_DM_REPLICATOR_POLICIES &&
+		    nrsite.policy != DM_REPLICATOR_SYNC) {
+			log_error("For asynchronous site policy an asynchronous "
+				  "non-zero parameter must be specified.");
+			return 0;
+		}
+		nrsite.policy = DM_REPLICATOR_SYNC;
+	}
+
+	if (rsite->policy != nrsite.policy) {
+		rsite->policy = nrsite.policy;
+		(*changed)++;
+	}
+
+	return 1;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index 71e516f..47f1d4d 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -115,4 +115,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
+int get_replicator_site_params(struct cmd_context *cmd,
+			       struct replicator_site *rsite,
+			       int *changed);
 #endif
-- 
1.7.2.1


