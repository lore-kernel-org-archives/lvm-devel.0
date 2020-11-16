From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 16 Nov 2020 11:15:50 +0800
Subject: [QEUSTION] VG refresh: remove disk and reinsert disk, VG not refresh
Message-ID: <7b0ca534-c927-7e15-a6ce-52edc5a1805d@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We use LVM2.02.187 to create a logical volume on the disk,
and then remove the disk and reinsert it. When reading and
writing the logical volume, IO error occurred. But LVM2.02.181
version can be used normally.

If remove disk and reinsert disk, drive letter has changed.
Maybe /dev/sda -> /dev/sdc

LVM 2.02.181: (vg autoactivate and refresh)
# lsblk

/dev/sda (8:16)		/dev/sdc (8:32)
   |		---->      |
   |----vg-lv		   |----vg-lv

# dmsetup table

vg-lv: 0 20963328 linear 8:16 2048  ----->  vg-lv: 0 20963328 linear 8:32 2048


_pvscan_autoactivate
	|
	|----_pvscan_autoactivate_single
			|
			|----vg_refresh_visible
				  |
				  |----lv_refresh ( refresh lv table, change dm-target)



LVM 2.02.187 and later (vg autoactivate but not refresh)

#lsblk

/dev/sda (8:16)		/dev/sdc (8:32)
   |		---->      |
   |----vg-lv		   |---- nothing

#dmsetup table

vg-lv: 0 20963328 linear 8:16 2048 (not change, so read/write lv failed.)


_pvscan_autoactivate
	|
	|----_pvscan_autoactivate_single
			|
			|---- vg_refresh_visible ( skip, so lv not refresh)

and later version, _pvscan_autoactivate_single has deleted.


So I want to know how to add vg refresh function in the 2.02.187 and later to keep it the same as 2.02.181,
and why delete vg refresh function?

Thanks.


