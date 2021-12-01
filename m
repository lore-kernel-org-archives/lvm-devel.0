From: David Teigland <teigland@sourceware.org>
Date: Wed,  1 Dec 2021 14:56:32 +0000 (GMT)
Subject: main - tests devicesfile-devname.sh drop mdadm chunk
Message-ID: <20211201145632.C7C803858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71e7ebb3e409be91b6c29e25ebfdd73c27f02902
Commit:        71e7ebb3e409be91b6c29e25ebfdd73c27f02902
Parent:        36095ac374edeccd256bf565aa66d629ad5480c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 1 08:56:05 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 1 08:56:05 2021 -0600

tests devicesfile-devname.sh drop mdadm chunk

---
 test/shell/devicesfile-devname.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index a99fe3e9a..338637275 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -590,7 +590,7 @@ OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
 PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
 PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
 
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev3" "$dev4"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --raid-devices=2 "$dev3" "$dev4"
 wait_md_create "$mddev"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices


