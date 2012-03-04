From: ben <benscott@nwlink.com>
Date: Sun, 04 Mar 2012 14:05:05 -0800
Subject: Excessive lvreduce on snapshot doesn't show up as invalid snapshot
Message-ID: <78290424.X7tuqrmkrf@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If I have a snapshot and reduce it too far, it still shows as a valid
snap in 'lvs' on the attributes line.


# lvs
  LV           VG      Attr   LSize  Origin       Snap%  Move Log Copy%  
Convert
  OriginVolume MyGroup owi-a- 98.46g
  SnapShot     MyGroup swi-a- 73.28g OriginVolume   0.73


# lvreduce --size 10M MyGroup/SnapShop

# lvs
  /dev/MyGroup/SnapShot: read failed after 0 of 4096 at 105725755392: 
Input/output error
  /dev/MyGroup/SnapShot: read failed after 0 of 4096 at 105725812736: 
Input/output error
  snapshot percentage too large
  dm_report_object: report function failed for field snap_percent
  LV           VG      Attr   LSize  Origin       Snap%  Move Log Copy%  
Convert
  OriginVolume MyGroup owi-a- 98.46g
  SnapShot     MyGroup swi-a- 12.00m OriginVolume



lvs --version
  LVM version:     2.02.88(2) (2011-08-19)
  Library version: 1.02.67 (2011-08-19)
  Driver version:  4.22.0




