From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:34:09 +0000 (UTC)
Subject: master - WHATS_NEW: recent commits - config value format flags
Message-ID: <20150624093409.2C82D60F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a25d92c88b034996667da3764ac5b1de15448174
Commit:        a25d92c88b034996667da3764ac5b1de15448174
Parent:        982cf44ff0740c95c4125af1607cf2ed8a2aab69
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 24 11:33:34 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:34:02 2015 +0200

WHATS_NEW: recent commits - config value format flags

---
 WHATS_NEW_DM |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d4b1639..ce10238 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,8 @@
 Version 1.02.100 - 
 ================================
+  Add DM_CONFIG_VALUE_FMT_{INT_OCTAL,STRING_NO_QUOTES} config value format flag.
+  Add DM_CONFIG_VALUE_FMT_COMMON_{ARRAY,EXTRA_SPACE} config value format flag.
+  Add dm_config_value_{get,set}_format_flags to get and set config value format.
 
 Version 1.02.99 - 20th June 2015
 ================================


