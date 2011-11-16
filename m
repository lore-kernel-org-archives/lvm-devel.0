From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:52 +0100
Subject: [PATCH 05/12] Change default prefix.
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <8650c346f45e070961239cb02c3374a29262a908.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use ""  instead of "  ".
So commands like lvs print from the begining of the line.
(no need to trim space around).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 doc/example.conf.in   |    6 +++---
 lib/config/defaults.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 2dd1808..1bc6df7 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -258,9 +258,9 @@ log {
     command_names = 0
 
     # A prefix to use before the message text (but after the command name,
-    # if selected).  Default is two spaces, so you can see/grep the severity
-    # of each message.
-    prefix = "  "
+    # if selected). Set to "  " to revert to the default behaviour
+    # prior to version 2.02.89.
+    prefix = ""
 
     # To make the messages look similar to the original LVM tools use:
     #   indent = 0
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9b91aea..5691d56 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -96,7 +96,7 @@
 #define DEFAULT_MAXIMISE_CLING 1
 #define DEFAULT_CLUSTERED 0
 
-#define DEFAULT_MSG_PREFIX "  "
+#define DEFAULT_MSG_PREFIX ""
 #define DEFAULT_CMD_NAME 0
 #define DEFAULT_OVERWRITE 0
 
-- 
1.7.7.3


