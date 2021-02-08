From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:44:58 +0000 (GMT)
Subject: main - pvscan: support disabled event_activation
Message-ID: <20210208224458.23E22384A02A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2be585b79c71b8f70c0252af5f09dbd5e6103030
Commit:        2be585b79c71b8f70c0252af5f09dbd5e6103030
Parent:        018bba897ca13521988eb36a89fd054e15feb231
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 16:28:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:18:44 2021 +0100

pvscan: support disabled event_activation

In past we had this control with use_lvmetad check for
pvscan --cache -aay

Howerer this got lost with lvmetad removal commit:
117160b27e510dceb1ed6acf995115c040acd88d

When user sets lvm.conf global/event_activation=0
pvscan service will no longer auto activate any LVs on appeared PVs.
---
 tools/pvscan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index dc24f4e34..f7aaf8ab9 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1581,6 +1581,12 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	dm_list_init(&complete_vgnames);
 
+	if (do_activate &&
+	    !find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
+		log_verbose("Ignoring pvscan --cache -aay because event_activation is disabled.");
+		return ECMD_PROCESSED;
+	}
+
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 


