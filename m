From: Dongmao Zhang <dmzhang@suse.com>
Date: Tue, 27 Aug 2013 18:00:05 +0800
Subject: LVM2 test script failed, is it a read_ahead bug?
Message-ID: <521C78A5.5000108@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dear mail-list,
    I met this in running the test case for lvm:
sh shell/read-ahead.sh FAILED:

#COMM "read ahead is properly inherited from underlying PV"
blockdev --setra 768 "$dev1"
#read-ahead.sh:34+ blockdev --setra 768 @TESTDIR@/dev/mapper/@PREFIX at pv1
vgscan
#read-ahead.sh:35+ vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "@PREFIX at vg" using metadata type lvm2
  WARNING: This metadata update is NOT backed up
lvcreate -n $lv -L4m $vg "$dev1"
#read-ahead.sh:36+ lvcreate -n LV -L4m @PREFIX at vg
@TESTDIR@/dev/mapper/@PREFIX at pv1
  WARNING: This metadata update is NOT backed up
  WARNING: This metadata update is NOT backed up
  Logical volume "LV" created
test $(blockdev --getra $DM_DEV_DIR/$vg/$lv) -eq 768
blockdev --getra $DM_DEV_DIR/$vg/$lv
##read-ahead.sh:37+ blockdev --getra @TESTDIR@/dev/@PREFIX at vg/LV
#read-ahead.sh:37+ test 1024 -eq 768

The read_ahead of underlying device was set to 768. After creating the
logical volume device, lvm found the auto read ahead was 1024 which is
bigger than 768. So lvm selected the bigger number(1024) to the
read_ahead of logical volume.

However I think we should use the minimal read_ahead in underlying
device and auto-detected kernel parameter. if so, this behavior could be
consistent with the test script.

I suggest use:

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9043352..b9000f9 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1225,7 +1225,7 @@ static int _set_dev_node_read_ahead(const char
*dev_name,
                if (!get_dev_node_read_ahead(dev_name, major, minor,
&current_read_ahead))
                        return_0;

-               if (current_read_ahead >= read_ahead) {
+               if (current_read_ahead <= read_ahead) {
                        log_debug_activation("%s: retaining kernel read
ahead of %" PRIu32
                                  " (requested %" PRIu32 ")",
                                  dev_name, current_read_ahead, read_ahead);

If I am wrong, please correct me:)

thank you










