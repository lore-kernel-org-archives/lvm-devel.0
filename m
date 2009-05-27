From: Milan Broz <mbroz@redhat.com>
Date: Wed, 27 May 2009 14:38:32 +0200
Subject: [PATCH] More fixes for virtual origin
In-Reply-To: <Pine.LNX.4.64.0905270759310.4445@hs20-bc2-1.build.redhat.com>
References: <4A1C2FFF.8050604@redhat.com>	<Pine.LNX.4.64.0905270711490.29054@hs20-bc2-1.build.redhat.com>	<4A1D2438.6070500@redhat.com>
	<Pine.LNX.4.64.0905270759310.4445@hs20-bc2-1.build.redhat.com>
Message-ID: <4A1D3448.4070102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

More fixes for virtual origin (applied over patch above)

 * try to load dm_zero using modprobe if not present

 * remove virtual origin from metadata if activate fails

 * fail if residual vorigin exist and do not create LV with duplicate name

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/zero/zero.c  |    2 +-
 tools/lvcreate.c |    8 ++++++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index acf6453..7b3e62e 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -58,7 +58,7 @@ static int _zero_target_present(struct cmd_context *cmd,
 	static int _zero_present = 0;
 
 	if (!_zero_checked)
-		_zero_present = target_present(cmd, "zero", 0);
+		_zero_present = target_present(cmd, "zero", 1);
 
 	_zero_checked = 1;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8d4ec23..cfdd589 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -576,6 +576,12 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (find_lv_in_vg(vg, vorigin_name)) {
+		log_error("Virtual origin LV %s already exists in "
+			  "volume group %s.", vorigin_name, vg->name);
+		return 0;
+	}
+
 	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
 				   ALLOC_INHERIT, vg)))
 		return_0;
@@ -920,6 +926,8 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			if (!org || !activate_lv(cmd, org)) {
 				log_error("Couldn't create virtual origin "
 					  "for LV %s", lv->name);
+				if (org && !lv_remove(org))
+					stack;
 				goto deactivate_and_revert_new_lv;
 			}
 		}



