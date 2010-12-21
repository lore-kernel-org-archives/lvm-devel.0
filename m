From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:53 +0100
Subject: [PATCH 21/23] Add default error path for get_property
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <448fdedd7f429eb2a94c0f31ed4b85a7fb73eea1.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set invalid property value for error path when none of handlers is set.
Fixes use of uninitialized prop variable.

Maybe add log_error() for this programming error?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 liblvm/lvm_misc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 62fef61..e2937c9 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -78,7 +78,11 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 			v.is_valid = 0;
 			return v;
 		}
+	} else {
+		v.is_valid = 0;
+		return v;
 	}
+
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
 	v.is_integer = prop.is_integer;
-- 
1.7.3.4


