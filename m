From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:29 +0000 (UTC)
Subject: master - cleanup: add standard GPL file header
Message-ID: <20120823124229.A8DA9A33BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba309e0da5bd22f844dbfc284c1606ca413f79f7
Commit:        ba309e0da5bd22f844dbfc284c1606ca413f79f7
Parent:        b0b507b197588a25698cd876673f722b97bd18d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 01:15:45 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:20 2012 +0200

cleanup: add standard GPL file header

Add FIXME about DEBUG define colission.
---
 libdaemon/server/daemon-log.h |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-log.h b/libdaemon/server/daemon-log.h
index 17d8007..f09fc2a 100644
--- a/libdaemon/server/daemon-log.h
+++ b/libdaemon/server/daemon-log.h
@@ -1,14 +1,38 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_LOG_H
+#define _LVM_DAEMON_LOG_H
+
 enum { DAEMON_LOG_FATAL = 0 /* usually preceding daemon death */
      , DAEMON_LOG_ERROR = 1 /* something serious has happened */
      , DAEMON_LOG_WARN = 2 /* something unusual has happened */
      , DAEMON_LOG_INFO = 3 /* thought you might be interested */
      , DAEMON_LOG_WIRE = 4 /* dump traffic on client sockets */
      , DAEMON_LOG_DEBUG = 5 /* unsorted debug stuff */
-     };
+};
 
+/*
+ * FIXME: We are currently compiling with -DDEBUG
+ * so this define DEBUG collision needs fixing
+ */
+#undef DEBUG
 #define DEBUG(s, x...) daemon_logf((s)->log, DAEMON_LOG_DEBUG, x)
 #define DEBUG_cft(s, i, n) daemon_log_cft((s)->log, DAEMON_LOG_DEBUG, i, n)
 #define WARN(s, x...) daemon_logf((s)->log, DAEMON_LOG_WARN, x)
 #define INFO(s, x...) daemon_logf((s)->log, DAEMON_LOG_INFO, x)
 #define ERROR(s, x...) daemon_logf((s)->log, DAEMON_LOG_ERROR, x)
 #define FATAL(s, x...) daemon_logf((s)->log, DAEMON_LOG_FATAL, x)
+
+#endif


