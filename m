From: Daniel Mierswa <impulze@impulze.org>
Date: Fri, 14 Aug 2009 11:42:50 +0200
Subject: [PATCH] use /sbin/blkid from util-linux-ng for newer udev
Message-ID: <4A85319A.8030608@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

udev no longer provides vol_id and uses /sbin/blkid from util-linux-ng
(util-linux won't work)

see:
http://git.kernel.org/?p=linux/hotplug/udev.git;a=commitdiff;h=f07996885dab45102492d7f16e7e2997e264c725

Signed-off-by: Daniel Mierswa <impulze@impulze.org>
---
 udev/12-dm-disk.rules |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/12-dm-disk.rules b/udev/12-dm-disk.rules
index 4b81420..b1e6cd2 100644
--- a/udev/12-dm-disk.rules
+++ b/udev/12-dm-disk.rules
@@ -21,7 +21,7 @@ ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
-IMPORT{program}="vol_id --export $tempnode"
+IMPORT{program}="/sbin/blkid -o udev -p $tempnode"
 OPTIONS="link_priority=-100"
 ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
-- 
1.6.4


