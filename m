From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:23 +0000 (UTC)
Subject: master - coverity: cleaning some PW.NOT_COMPATIBLE_WITH_PREVIOUS_DECL
Message-ID: <20160713195623.881A56036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4661c6b6fb7adc01a3fd42b5e802051b92d15d9d
Commit:        4661c6b6fb7adc01a3fd42b5e802051b92d15d9d
Parent:        bbf574ab90a82f636a5f5e66c9523484492da946
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 16:42:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

coverity: cleaning some PW.NOT_COMPATIBLE_WITH_PREVIOUS_DECL

Some very low-prio warns....
---
 libdaemon/client/config-util.h   |    2 +-
 libdaemon/client/daemon-client.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 64cce8b..38f36af 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -26,7 +26,7 @@ int buffer_append_f(struct buffer *buf, ...);
 int buffer_append(struct buffer *buf, const char *string);
 void buffer_init(struct buffer *buf);
 void buffer_destroy(struct buffer *buf);
-int buffer_realloc(struct buffer *buf, int required);
+int buffer_realloc(struct buffer *buf, int needed);
 
 int buffer_line(const char *line, void *baton);
 
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 173ea89..5235bea 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -78,7 +78,7 @@ daemon_handle daemon_open(daemon_info i);
  * be ignored even if non-NULL). If the buffer is NULL, the cft is required to
  * be a valid pointer, and is used to build up the request.
  */
-daemon_reply daemon_send(daemon_handle h, daemon_request r);
+daemon_reply daemon_send(daemon_handle h, daemon_request rq);
 
 /*
  * A simple interface to daemon_send. This function just takes the command id


