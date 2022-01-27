From: David Teigland <teigland@redhat.com>
Date: Thu, 27 Jan 2022 11:50:03 -0600
Subject: Reg a deadlock specific to our environment
In-Reply-To: <CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
References: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
	<20220113145226.GA436@redhat.com>
	<CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
Message-ID: <20220127175003.GA2976@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 26, 2022 at 06:41:07PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> Attached output of lvs -vvv wherein the lvm2 call tries to read a
> dmcrypt volume whose source is a pxd device which is serviced by a
> userspace app.
> When this app is restarted, lvm2 sanity calls are made which gets stuck
> forever because a read on a virtual pxd device happens which cannot be
> serviced during startup.

> /// Created a dmcrypt volume and have it attached on the node. This is a
> new block device (/dev/mapper/pxd-enc405564132566284931)
> /// whose parent virtual pxd device is (/dev/pxd/pxd/pxd405564132566284931)

> pxd!pxd405564132566284931                  252:1    0    10G  0 disk
> ??pxd-enc405564132566284931                253:11   0    10G  0 crypt

It sounds like lvm gets stuck reading dm device 253:11, not 252:1?

> [root at ip-70-0-159-14 ~]# ls -al /dev/pxd/pxd405564132566284931
> brw-rw---- 1 root disk 252, 1 Jan 26 12:36 /dev/pxd/pxd405564132566284931

Please confirm that lvm is ignoring 252:1, because I don't think it
recognizes that device type.  (See filter-type.c, dev_type_array,
_dev_known_types, and create_dev_types().)  It might be interesting to
know what /proc/devices shows for 252.

Also, dm devices with a certain reserved suffix will be ignored by lvm,
but lvm has to know about the suffixes it should ignore.  (See
filter-usable.c, device_is_usable(), _is_usable_uuid().)  Should you be
using a reserved dm uuid suffix that lvm should be told about?

> lr-x------ 1 root root 64 Jan 26 12:41 9 -> /dev/dm-11
> ///// This is /dev/mapper/pxd-enc405564132566284931

> <<<<<<< Stuck here for disk IO - waiting for read from dmcrypt
> volume(/dev/mapper/pwx0-405564132566284931)
> whose parent device /dev/pxd/pxd/pxd405564132566284931, which is not going
> to be serviced since the application is down.

> 10331 open("/dev/mapper/pxd-enc405564132566284931",
> O_RDONLY|O_DIRECT|O_NOATIME) = 9</dev/dm-11>
> 10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
> aio_fildes=9</dev/dm-11>, aio_buf=0x555bdebb2000, aio_nbytes=131072,
> aio_offset=0}]) = 1
> 
> ^^^^^ The above is the trouble, where the lvs (or any vg open call from
> code) will read all dm devices that includes dm-crypt volumes too whose
> source is not ready now, thereby waiting forever.

You seem to be saying that lvm is stuck reading both
/dev/pxd/pxd/pxd405564132566284931 and /dev/mapper/pxd-enc405564132566284931a?

Please send complete dmsetup info/status/table details for the dm devices
that lvm is stuck reading.  If a device is suspended, then lvm would
ignore it (also in _passes_usable_filter().)

udev/blkid may also be stuck scanning one of your devices that can't be
read, so lvm commands may not be your only problem.

Dave


