From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 12 Feb 2010 17:14:10 -0500
Subject: [PATCH] Ignore _mlog name restriction for lvconvert repair
In-Reply-To: <CA32D663-C193-48B6-9DA8-F2376C584385@redhat.com>
References: <471e224a57131c07b705.1265821968@localhost>	<4B746099.7010709@redhat.com>	<20100211203827.GA27416@us.ibm.com>
	<4B74AB63.9090706@redhat.com>
	<CA32D663-C193-48B6-9DA8-F2376C584385@redhat.com>
Message-ID: <4B75D2B2.2090809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Jon,

> Taka, I've not been able to reproduce your seg faults with '--alloc  
> anywhere' using two devices.  Is there a special restriction you are  
> using?

Here is the reproduction steps.

[case 1]
1. create VG with two devices.
  # vgcreate vg00 /dev/sd[ab]

2. create LV with mirrored log
  # lvcreate -m1 -L12m -nlv00 --mirrorlog mirrored --alloc anywhere vg00

3. disable device /dev/sdb
  # echo offline > /sys/block/sdb/device/state

4. Write data
  # dd if=/dev/zero of=/dev/vg00/lv00 bs=4096 count=1
  1+0 records in
  1+0 records out
  4096 bytes (4.1 kB) copied, 3.02835 seconds, 1.4 kB/s

5. convert LV to mirrored log
  # lvconvert -m1 --mirrorlog mirrored --alloc anywhere vg00/lv00
    /dev/sdd: open failed: No such device or address
  Segmentation fault

[case 2]
  # vgs
    No volume groups found
  # vgcreate vg00 /dev/sdc
    Volume group "vg00" successfully created
  # lvcreate -m1 -L12m -nlv00 --mirrorlog mirrored --alloc anywhere vg00
  Segmentation fault

I hope you could reproduce this issues.

Thanks,
Taka


