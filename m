From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:00:50 +0000 (UTC)
Subject: master - libdaemon: fix misleading "WARNING: Ignoring unsupported value for expected." when communicating with daemon
Message-ID: <20140325100050.B533B60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c84face8ceec82123a5d4ecc309ab9bb7fbbfddf
Commit:        c84face8ceec82123a5d4ecc309ab9bb7fbbfddf
Parent:        9446978e642c8f580386aa0279910553ab540fad
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 24 16:47:08 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 16:47:08 2014 +0100

libdaemon: fix misleading  "WARNING: Ignoring unsupported value for expected." when communicating with daemon

When we're trying to search for certain tree node
in daemon's reply, we default to a blank string ""
if the node is not found. This happens during lvmetad
initialization.

However, when the default blank string is used, we
can't use dm_config_find_str at the same time - the
dm_config_find_str_allow_empty should be used instead.
Otherwise a a warning message:

  "WARNING: Ignoring unsupported value for ..."

is issued.
---
 libdaemon/client/daemon-client.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 6ba65e6..8a44f8b 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -102,7 +102,7 @@ static inline int64_t daemon_reply_int(daemon_reply r, const char *path, int64_t
 }
 
 static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {
-	return dm_config_find_str(r.cft->root, path, def);
+	return dm_config_find_str_allow_empty(r.cft->root, path, def);
 }
 
 


