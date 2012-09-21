From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 21 Sep 2012 15:26:26 -0500
Subject: [PATCH] Add missing lvm_percent_to_float
Message-ID: <1348259186-12157-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_misc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 0a0ea12..66dcdef 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -114,3 +114,8 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 	}
 	return 0;
 }
+
+float lvm_percent_to_float(percent_t v)
+{
+    return percent_to_float(v);
+}
-- 
1.7.11.4


