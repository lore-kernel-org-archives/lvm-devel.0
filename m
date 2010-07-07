From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:50 +0200
Subject: [PATCH 16/22] Replicator: read site_params
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <c562a163231bcec800c9e794d1f4768eaa17c141.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Common function for parsing replicator site parameters.
It's used by lvcreate and lvchange command in later patch.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |  111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    3 +
 2 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bdb52d5..f1da944 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1551,3 +1551,114 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
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
+	if (arg_count(cmd, fallbehinddata_ARG)) {
+		nrsite.fall_behind_data =
+			arg_uint64_value(cmd, fallbehinddata_ARG,
+					 DEFAULT_REPLICATOR_FALL_BEHIND_DATA);
+		if (rsite->fall_behind_data != nrsite.fall_behind_data) {
+			rsite->fall_behind_data = nrsite.fall_behind_data;
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+		}
+	}
+
+	if (arg_count(cmd, fallbehindios_ARG)) {
+		if (arg_count(cmd, fallbehinddata_ARG)) {
+			log_error("Only one asynchronous parameter can be used.");
+			return 0;
+		}
+		nrsite.fall_behind_ios =
+			arg_uint_value(cmd, fallbehindios_ARG,
+				       DEFAULT_REPLICATOR_FALL_BEHIND_IOS);
+
+		if (rsite->fall_behind_ios != nrsite.fall_behind_ios) {
+			rsite->fall_behind_data = 0;
+			rsite->fall_behind_ios = nrsite.fall_behind_ios;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+		}
+	}
+
+	if (arg_count(cmd, fallbehindtimeout_ARG)) {
+		if (arg_count(cmd, fallbehinddata_ARG) ||
+		    arg_count(cmd, fallbehindios_ARG)) {
+			log_error("Only one asynchronous parameter can be used.");
+			return 0;
+		}
+		nrsite.fall_behind_timeout =
+			arg_uint_value(cmd, fallbehindtimeout_ARG,
+				       DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT);
+
+		if (rsite->fall_behind_timeout != nrsite.fall_behind_timeout) {
+			rsite->fall_behind_data = 0;
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_timeout = nrsite.fall_behind_timeout;
+			(*changed)++;
+		}
+	}
+
+	nrsite.op_mode = NUM_DM_REPLICATOR_MODES;
+	if (arg_count(cmd, sitemode_ARG)) {
+		nrsite.op_mode = arg_uint_value(cmd, sitemode_ARG,
+						DEFAULT_REPLICATOR_ASYNC_MODE);
+		if ((nrsite.op_mode == DM_REPLICATOR_SYNC) &&
+		    !arg_count(cmd, fallbehinddata_ARG) &&
+		    !arg_count(cmd, fallbehindios_ARG) &&
+		    !arg_count(cmd, fallbehindtimeout_ARG) &&
+		    (rsite->fall_behind_data ||
+		     rsite->fall_behind_ios ||
+		     rsite->fall_behind_timeout)) {
+			rsite->fall_behind_data = 0;
+			rsite->fall_behind_ios = 0;
+			rsite->fall_behind_timeout = 0;
+			(*changed)++;
+			log_debug("Clearing asynchronous parameters synchronous site.");
+		}
+	}
+
+	if (rsite->fall_behind_data ||
+	    rsite->fall_behind_ios ||
+	    rsite->fall_behind_timeout) {
+		if (!rsite->vg_name) {
+			log_error("Cannot set asynchronous parameters for "
+				  "the local site %s.", rsite->name);
+			return 0;
+		}
+		if (nrsite.op_mode == DM_REPLICATOR_SYNC) {
+			log_error("For synchronous site mode all asynchronous "
+				  "parameters must be deleted.");
+			return 0;
+		} else if (nrsite.op_mode == NUM_DM_REPLICATOR_MODES)
+			nrsite.op_mode = (rsite->op_mode == DM_REPLICATOR_SYNC) ?
+				DEFAULT_REPLICATOR_ASYNC_MODE : rsite->op_mode;
+	} else {
+		if (nrsite.op_mode != NUM_DM_REPLICATOR_MODES &&
+		    nrsite.op_mode != DM_REPLICATOR_SYNC) {
+			log_error("For asynchronous site mode an asynchronous "
+				  "non-zero parameter must be specified.");
+			return 0;
+		}
+		nrsite.op_mode = DM_REPLICATOR_SYNC;
+	}
+
+	if (rsite->op_mode != nrsite.op_mode) {
+		rsite->op_mode = nrsite.op_mode;
+		(*changed)++;
+	}
+
+	return 1;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index daab95a..1d3d3c1 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -118,4 +118,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
+int get_replicator_site_params(struct cmd_context *cmd,
+			       struct replicator_site *rsite,
+			       int *changed);
 #endif
-- 
1.7.1.1


