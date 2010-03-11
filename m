From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 11 Mar 2010 17:53:00 -0500
Subject: [PATCH 0 of 10] LVM: mirrored log patches
In-Reply-To: <1267833465.10315.3.camel@hydrogen.msp.redhat.com>
References: <1267833465.10315.3.camel@hydrogen.msp.redhat.com>
Message-ID: <4B99744C.6060607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/05/10 18:57, Jonathan Brassow wrote:
> There will likely be at least one more round of these patches - mostly
> to clean-up the last patch I've been working on.
> 
> This round includes changes to the _lvconvert_mirrors function to allow
> it to handle the repair conversions necessary for 'lvconvert' to accept
> only top-level LVs.  It also includes suggested changes from Taka
> (thanks for those!).

I didn't have time to investigate the root cause, but let me report
an error case I found. When the secondary log device has a failure,
lvconvert couldn't recover the mirror device, but other cases,
the primary mirror leg failure, the secondary mirror leg failure and
the primary log device failure worked fine.

This is reproduction steps.

1. create mirror device

vg00-lv00 (253:5)
 |-vg00-lv00_mimage_1 (253:4)
 |  `- (8:48)
 |-vg00-lv00_mimage_0 (253:3)
 |  `- (8:32)
 `-vg00-lv00_mlog (253:2)
    |-vg00-lv00_mlog_mimage_1 (253:1)
    |  `- (8:80)
    `-vg00-lv00_mlog_mimage_0 (253:0)
       `- (8:64)

2. kill dmeventd

3. disable the secondary device of the mirrored log

# echo offline > /sys/block/sdf/device/state

4. write to the mirror device

# dd if=/dev/zero of=/dev/vg00/lv00 bs=4096 count=1
*** hungup ***

5. check the device status

# dmsetup status
vg00-lv00_mimage_1: 0 24576 linear 
vg00-lv00_mlog_mimage_1: 0 8192 linear 
vg00-lv00_mimage_0: 0 24576 linear 
vg00-lv00_mlog_mimage_0: 0 8192 linear 
vg00-lv00_mlog: 0 8192 mirror 2 253:0 253:1 7/8 1 AD 1 core
vg00-lv00: 0 24576 mirror 2 253:3 253:4 24/24 1 AA 3 disk 253:2 A

6. execute lvconvert command

# lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies vg00/lv00
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Mirror log status: 1 of 2 images failed
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  Couldn't find device with uuid 'KxT1Vd-czbx-mWS1-1F8E-WO3k-rvUA-z41gwY'.
  device-mapper: create ioctl failed: Device or resource busy
  Problem reactivating lv00_mlog
  WARNING: dev_open(/etc/lvm/lvm.conf) called while suspended

After this steps, dmsetup vg00-lv00 also hungup.
I'll report if I get more information.

Thanks,
Taka


