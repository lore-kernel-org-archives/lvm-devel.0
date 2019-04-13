From: Eric Ren <renzhengeek@gmail.com>
Date: Sat, 13 Apr 2019 19:32:15 +0800
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <CAKM4AezfHJ1V+UvDKX_9=VPPdHK9btGGK9AFJXihwY3D2s99fw@mail.gmail.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
	<CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
	<CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
	<CAKM4AewQpxTmRZ=GNqCaEb0yL=5ukVUNrhWJ-bFnXeaFoiJh4Q@mail.gmail.com>
	<a719d149-c9af-98e3-8983-5418584b11b0@redhat.com>
	<CAKM4AezfHJ1V+UvDKX_9=VPPdHK9btGGK9AFJXihwY3D2s99fw@mail.gmail.com>
Message-ID: <CAKM4Aexrgzf9Gn6JL4rXPa=0akPr+AiVkwZW9D_Mdoup7nPZLw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> Since you are using very ancient lvm2  (2.02.130) we have heavily improved
> > logic for such pools over the time...
>
> Hah, I think I've mentioned this issue can be reproduced on centos 7.6
> (2.02.180).

This issue happens again on centos 7.6, the logs will be attached.

"lvcreate" hangs up to create vg0/19 (dm-23), origin LV - vg0/RootVolume(dm-4):

```
# ps aux|grep lvcreate
root     11979  0.0  0.0 168804 12920 ?        S    14:35   0:00
lvcreate -K --type thin -s vg0/RootVolume -n 19
```

systemd udev logs:
```
4? 13 14:38:46 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: Validate
module index
4? 13 14:38:46 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: Check if
link configuration needs reloading.
4? 13 14:38:49 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: worker
[11992] /devices/virtual/block/dm-4 timeout; kill it
4? 13 14:38:49 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: seq 4348
'/devices/virtual/block/dm-4' killed
4? 13 14:38:49 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: worker
[12003] /devices/virtual/block/dm-23 timeout; kill it
4? 13 14:38:49 iZuf6dbyd7ede51sykedamZ systemd-udevd[7968]: seq 4351
'/devices/virtual/block/dm-23' killed
```

The udev info of the thin LV when "lvcreate" hangs up as follows:

- origin LV:
```
# udevadm info /sys//devices/virtual/block/dm-4

calling: inf
P: //devices/virtual/block/dm-4
N: dm-4
S: disk/by-id/dm-name-vg0-RootVolume
S: disk/by-id/dm-uuid-LVM-VFXfDG8OWjBHGJ8Bp6ipjiNclYdTdX0oR3aPZa6aEpDfjksiciXtYHlK8gRraSyl
S: disk/by-uuid/cd626b0d-f208-4075-a86f-d32cf64ae726
S: mapper/vg0-RootVolume
S: vg0/RootVolume
E: DEVLINKS=/dev/disk/by-id/dm-name-vg0-RootVolume
/dev/disk/by-id/dm-uuid-LVM-VFXfDG8OWjBHGJ8Bp6ipjiNclYdTdX0oR3aPZa6aEpDfjksiciXtYHlK8gRraSyl
/dev/disk/by-uuid/cd626b0d-f208-4075-a86f-d32cf64ae726
/dev/mapper/vg0-RootVolume /dev/vg0/RootVolume
E: DEVNAME=/dev/dm-4
E: DEVPATH=//devices/virtual/block/dm-4
E: DEVTYPE=disk
E: DM_ACTIVATION=1
E: DM_LV_NAME=RootVolume
E: DM_NAME=vg0-RootVolume
E: DM_SUSPENDED=0
E: DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG=1
E: DM_UDEV_PRIMARY_SOURCE_FLAG=1
E: DM_UDEV_RULES_VSN=2
E: DM_UUID=LVM-VFXfDG8OWjBHGJ8Bp6ipjiNclYdTdX0oR3aPZa6aEpDfjksiciXtYHlK8gRraSyl
E: DM_VG_NAME=vg0
E: ID_FS_TYPE=ext4
E: ID_FS_USAGE=filesystem
E: ID_FS_UUID=cd626b0d-f208-4075-a86f-d32cf64ae726
E: ID_FS_UUID_ENC=cd626b0d-f208-4075-a86f-d32cf64ae726
E: ID_FS_VERSION=1.0
E: MAJOR=252
E: MINOR=4
E: SUBSYSTEM=block
E: TAGS=:systemd:
E: USEC_INITIALIZED=50694114
```

- the creating snapshot
```
# udevadm info /sys//devices/virtual/block/dm-23
calling: info
P: //devices/virtual/block/dm-23
N: dm-23
E: DEVNAME=/dev/dm-23
E: DEVPATH=//devices/virtual/block/dm-23
E: DEVTYPE=disk
E: DM_UDEV_DISABLE_DISK_RULES_FLAG=1
E: DM_UDEV_DISABLE_OTHER_RULES_FLAG=1
E: DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG=1
E: MAJOR=252
E: MINOR=23
E: SUBSYSTEM=block
E: SYSTEMD_READY=0
E: TAGS=:systemd:
E: USEC_INITIALIZED=1441731331
```

It looks like the 10-dm.rules is not applied to dm-23, because the
DM_UDEV_PRIMARY_SOURCE_FLAG='1' ENV is not set yet, which is put in by
this rule:

```
ENV{DM_COOKIE}=="?*", IMPORT{program}="/usr/sbin/dmsetup udevflags
$env{DM_COOKIE}"
```

Another point I don't understand is, why the origin LV (RootVolume)
generates uevent when createing snapshot based on it?

Regards,
Eric
-------------- next part --------------
A non-text attachment was scrubbed...
Name: udevadm-monitor.log
Type: application/octet-stream
Size: 16878 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190413/bf1ca501/attachment.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm-disk-udev-env.log
Type: application/octet-stream
Size: 2980 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190413/bf1ca501/attachment-0001.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: syslog-udev.log
Type: application/octet-stream
Size: 2093915 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190413/bf1ca501/attachment-0002.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2.log
Type: application/octet-stream
Size: 3032086 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190413/bf1ca501/attachment-0003.obj>
