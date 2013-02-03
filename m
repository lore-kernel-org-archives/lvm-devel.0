From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 03 Feb 2013 02:27:31 -0600
Subject: [PATCH 0 of 3] Allow faulty RAID PVs to be replaced with error segments
Message-ID: <1359880051.15387.8.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are currently two options for handling a failed PV in a RAID LV -
"warn" or "replace".  There is no option to "remove".  If the failed
device is never replaced, the user will continue to recieve error
messages whenever LVM commands are run.  The user may wish to remove the
failed device from their VG, but they are currently unable to because
'vgreduce --removemissing' does not work on PVs that are contained in a
RAID LV.  This is especially annoying to users who do not have spare
PVs, do not intend to add a spare, and cannot repair the failed PVs.

The following 3 patches address this situation:
1) Make vgreduce work with RAID LVs
2) Allow down-convert to work on RAID images with error segments
3) Allow lvconvert repair to work on RAID images with error segments 

 brassow


