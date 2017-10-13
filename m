From: Thomas Lamprecht <t.lamprecht@proxmox.com>
Date: Fri, 13 Oct 2017 11:08:42 +0200
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
Message-ID: <20171013090842.28186-1-t.lamprecht@proxmox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Else, lvmetad always gets started due to systemds socket auto
activation when executing, for example:
 # pvscan --cache
as pvscan uses lvmetad_is_disabled to check if metad is disabled
before connecting. This is OK for systems where systemd is not used
but for others, the systemd 'auto activation on socket connect'
feature causes the start of lvm2-lvmetad.service which is not desired
when disabled in the config.

ref: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826570
Signed-off-by: Thomas Lamprecht <t.lamprecht@proxmox.com>
---

An alternative approach would be to just guard the lvmetad_is_disabled
call in tools/pvscan.c : 412 with the config check - and thus address
the FIXME mentioned there.
Would be maybe the less intrusive version?

RFC.

 lib/cache/lvmetad.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1ba844fc8..94fba8979 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2846,6 +2846,12 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 	const char *reply_reason;
 	int ret = 0;
 
+	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
+		*reason = "the disable flag was set directly";
+		ret = 1;
+		goto out;
+	}
+
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
 				   "pid = " FMTd64, (int64_t)getpid(),
-- 
2.11.0



