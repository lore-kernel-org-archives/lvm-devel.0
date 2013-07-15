From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:02:55 +0000 (UTC)
Subject: master - libdm: remove unneeded read_ahead settings
Message-ID: <20130715140255.3837160642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5c30061fc5652846a61fcd460c6a1636d346a7c
Commit:        e5c30061fc5652846a61fcd460c6a1636d346a7c
Parent:        55d90b64207739ddee710f40cab8b71fc45d9849
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:41:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:43:28 2013 +0200

libdm: remove unneeded read_ahead settings

Skip settings are read_ahead value which is already set in kernel.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2fc454b..e784ada 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Optimize out setting the same value or read_ahead.
   Add DM_ARRAY_SIZE public macro.
   Move syslog code out of signal handle in dmeventd.
   Add DM_TO_STRING public macro.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d18de9c..8d5eca8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1221,7 +1221,7 @@ static int _set_dev_node_read_ahead(const char *dev_name,
 		if (!get_dev_node_read_ahead(dev_name, major, minor, &current_read_ahead))
 			return_0;
 
-		if (current_read_ahead > read_ahead) {
+		if (current_read_ahead >= read_ahead) {
 			log_debug_activation("%s: retaining kernel read ahead of %" PRIu32
 				  " (requested %" PRIu32 ")",           
 				  dev_name, current_read_ahead, read_ahead);


