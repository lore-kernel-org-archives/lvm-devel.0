From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Wed, 9 Jun 2021 17:33:22 +0800
Subject: [PATCH]dm-disk.rules: check DM_NAME before create symlink
Message-ID: <549f4ff3-20af-a482-d7c1-ff7613835002@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

We found that after deleting the dm device, there are still soft links left.

Before creating a symlink, need to determine whether DM_NAME exists.
Otherwise there will be a soft link left when you remove the dm device

udevd log:
localhost.localdomain systemd-udevd[3177745]: dm-68: /usr/lib/udev/rules.d/13-dm-disk.rules:17 LINK 'disk/by-id/dm-name-'
localhost.localdomain systemd-udevd[3177745]: dm-68: /usr/lib/udev/rules.d/13-dm-disk.rules:23 Importing properties from results of builtin command 'blkid'

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 udev/13-dm-disk.rules.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 535581070..fcb2f375c 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -14,7 +14,7 @@ ACTION!="add|change", GOTO="dm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"

-SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
+ENV{DM_NAME}=="?*", SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"

 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
-- 

Wu Guanghao


