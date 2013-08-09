From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Aug 2013 11:26:11 +0000 (UTC)
Subject: master - workaround: gcc v4.8 on 32 bit param. passing bug when -02 opimization used
Message-ID: <20130809112611.CAB576142F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f61478436a7ebe058ffad3f92e1c4dada0805d0
Commit:        2f61478436a7ebe058ffad3f92e1c4dada0805d0
Parent:        8d3347f70be96558d830409770156b0a01815212
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 9 13:06:17 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 9 13:24:50 2013 +0200

workaround: gcc v4.8 on 32 bit param. passing bug when -02 opimization used

gcc -O2 v4.8 on 32 bit architecture is causing a bug in parameter
passing. It does not happen with -01 nor -O0.

The problematic part of the code was strlen use in config.c in
the config_def_check fn and the call for _config_def_check_tree in it:

<snip>
  rplen = strlen(rp);
  if (!_config_def_check_tree(handle, vp, vp + strlen(vp), rp, rp + rplen, CFG_PATH_MAX_LEN - rplen, cn, cmd->cft_def_hash)) ...
</snip>

If compiled with -O0 (correct):

Breakpoint 1, config_def_check (cmd=0x819b050, handle=0x81a04f8) at config/config.c:775
(gdb) p	vp
$1 = 0x8189ee0 <_cfg_path> "config"
(gdb) p	strlen(vp)
$2 = 6
(gdb)
_config_def_check_tree (handle=0x81a04f8, vp=0x8189ee0 <_cfg_path>
"config", pvp=0x8189ee6 <_cfg_path+6> "", rp=0xbfffe1e8 "config",
prp=0xbfffe1ee "", buf_size=58, root=0x81a2568, ht=0x81a65
48) at config/config.c:680
(gdb) p	vp
$4 = 0x8189ee0 <_cfg_path> "config"
(gdb) p	pvp
$5 = 0x8189ee6 <_cfg_path+6> ""

If compiled with -O2 (incorrect):

Breakpoint 1, config_def_check (cmd=cmd at entry=0x8183050, handle=0x81884f8) at config/config.c:775
(gdb) p	vp
$1 = 0x8172fc0 <_cfg_path> "config"
(gdb) p strlen(vp)
$2 = 6
(gdb) p	vp + strlen(vp)
$3 = 0x8172fc6 <_cfg_path+6> ""
(gdb)
_config_def_check_tree (handle=handle at entry=0x81884f8, pvp=0x8172fc7
<_cfg_path+7> "host_list", rp=rp at entry=0xbffff190 "config",
prp=prp at entry=0xbffff196 "", buf_size=buf_size at entry=58, ht=0x
818e548, root=0x818a568, vp=0x8172fc0 <_cfg_path> "config") at
config/config.c:674
(gdb) p	pvp
$4 = 0x8172fc7 <_cfg_path+7> "host_list"

The difference is in passing the "pvp" arg for _config_def_check_tree.
While in the correct case, the value of _cfg_path+6 is passed
(the result of vp + strlen(vp) - see the snippet of the code above),
in the incorrect case, this value is increased by 1 to _cfg_path+7,
hence totally malforming the string that is being processed.

This ends up with incorrect validation check and incorrect warning
messages are issued like:

 "Configuration setting "config/checks" has invalid type. Found integer, expected section."

To workaround this issue, remove the "static" qualifier from the
"static char _cfg_path[CFG_PATH_MAX_LEN]". This causes the optimalizer
to be less aggressive (also shuffling the arg list for
_config_def_check_tree call helps).
---
 WHATS_NEW           |    1 +
 lib/config/config.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 773312e..7758500 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Workaround gcc v4.8 -O2 bug causing failures if config/checks=1 (32bit arch).
   Verify clvmd message validity before processing and log error if incorrect.
   Fix issue preventing PV creation on mirror LVs
   When converting mirrors, default segtype should be the same unless specified.
diff --git a/lib/config/config.c b/lib/config/config.c
index 2c2d9a3..6e93c40 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -56,7 +56,7 @@ struct config_source {
 	} source;
 };
 
-static char _cfg_path[CFG_PATH_MAX_LEN];
+char _cfg_path[CFG_PATH_MAX_LEN];
 
 /*
  * Map each ID to respective definition of the configuration item.


