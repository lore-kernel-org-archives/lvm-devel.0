From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 14:05:51 +0000 (UTC)
Subject: master - libdm: config: remove 4096 char limit due to buffer size if writing dm_config_node
Message-ID: <20160304140551.6486B60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=967a0889a024e2cc3f3afb3469e1b0657ebb85bc
Commit:        967a0889a024e2cc3f3afb3469e1b0657ebb85bc
Parent:        418b7c6be8e553c04eeeb8a96d6b3d4b1da1bb9a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 14:59:22 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 14:59:22 2016 +0100

libdm: config: remove 4096 char limit due to buffer size if writing dm_config_node

---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |   26 ++++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 174b6bd..d3eac29 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.119 -
 =====================================
+  Remove 4096 char limit due to buffer size if writing dm_config_node.
 
 Version 1.02.118 - 26th February 2016
 =====================================
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 25f85e5..a7f4096 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -222,19 +222,41 @@ __attribute__ ((format(printf, 2, 3)))
 static int _line_append(struct config_output *out, const char *fmt, ...)
 {
 	char buf[4096];
+	char *final_buf;
 	va_list ap;
 	int n;
 
+	/*
+	 * We should be fine with the 4096 char buffer 99% of the time,
+	 * but if we need to go beyond that, allocate the buffer dynamically.
+	 */
+
 	va_start(ap, fmt);
 	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
 	va_end(ap);
 
-	if (n < 0 || n > (int) sizeof buf - 1) {
+	if (n < 0) {
 		log_error("vsnprintf failed for config line");
 		return 0;
 	}
 
-	if (!dm_pool_grow_object(out->mem, &buf[0], strlen(buf))) {
+	if (n > (int) sizeof buf - 1) {
+		/*
+		 * Fixed size buffer with sizeof buf is not enough,
+		 * so try dynamically allocated buffer now...
+		 */
+		va_start(ap, fmt);
+		n = dm_vasprintf(&final_buf, fmt, ap);
+		va_end(ap);
+
+		if (n < 0) {
+			log_error("dm_vasprintf failed for config line");
+			return 0;
+		}
+	} else
+		final_buf = buf;
+
+	if (!dm_pool_grow_object(out->mem, final_buf, strlen(final_buf))) {
 		log_error("dm_pool_grow_object failed for config line");
 		return 0;
 	}


