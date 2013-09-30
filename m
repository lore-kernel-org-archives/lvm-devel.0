From: Alexander Tsoy <alexander@tsoy.me>
Date: Mon, 30 Sep 2013 22:18:59 +0400
Subject: lvmetad activation problem with MD devices
In-Reply-To: <20130930203615.59bfd346@work.puleglot>
References: <20130930203615.59bfd346@work.puleglot>
Message-ID: <20130930221859.45328e01@work.puleglot>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

? Mon, 30 Sep 2013 20:36:15 +0400
Alexander Tsoy <alexander@tsoy.me> ?????:

> Hello.
> 
> Commit 8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6 introduced the
> following problem. If MD device is assembled in initramfs and some LVs
> on it are not activated, then those LVs still not activated during
> system boot.
> 
> This, for example, breaks setups where initramfs is generated with
> dracut and LVs selectively activated using "rd.lvm.lv" kernel cmdline
> option.
> 

Just an example.

Setup:
md0 -> vg00 -> { lv00, lv01, lv02, lv03 }
md1 -> vg01 -> { lv04, lv05 }

Dracut options passed to the kernel cmdline:
rd.md.uuid=<UUID_of_md0> rd.lvm.lv=vg00/lv00 rd.lvm.lv=vg00/lv01

What happens in initramfs:
- md0 is assembled
- vg00/lv00 and vg00/lv01 are activated

What happens during system boot:
- md1 is assembled
- vg01/lv04 and vg01/lv05 are activated


vg00/lv02 and vg00/lv03 are not activated.

-- 
Alexander Tsoy


