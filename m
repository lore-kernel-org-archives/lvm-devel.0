From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Oct 2012 15:31:04 +0000 (UTC)
Subject: master - lvm2api: add defined lvm_percent_to_float
Message-ID: <20121011153104.472A6A0D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a46160d94524cca9d07e2d183d62ff6df1ec48e
Commit:        0a46160d94524cca9d07e2d183d62ff6df1ec48e
Parent:        316ce655a37136375dc9ea1204f218838d77ce41
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 11 17:25:14 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 11 17:29:56 2012 +0200

lvm2api: add defined lvm_percent_to_float

Implement function which was somehow missing from it's original
placement in the header file lvm2api.h.
---
 WHATS_NEW         |    1 +
 liblvm/lvm_base.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a3364a..d614270 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add implementation of lvm2api function lvm_percent_to_float.
   Allow non power of 2 thin chunk sizes if thin pool driver supports that.
   Allow limited metadata changes when PVs are missing via [vg|lv]change.
   Do not start dmeventd for lvchange --resync when monitoring is off.
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 815151e..01ea0d7 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -126,3 +126,8 @@ const char *lvm_vgname_from_device(lvm_t libh, const char *device)
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 	return find_vgname_from_pvname(cmd, device);
 }
+
+float lvm_percent_to_float(percent_t v)
+{
+	return percent_to_float(v);
+}


