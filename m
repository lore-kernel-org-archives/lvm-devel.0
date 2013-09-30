From: Alexander Tsoy <alexander@tsoy.me>
Date: Mon, 30 Sep 2013 20:36:15 +0400
Subject: lvmetad activation problem with MD devices
Message-ID: <20130930203615.59bfd346@work.puleglot>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello.

Commit 8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6 introduced the
following problem. If MD device is assembled in initramfs and some LVs
on it are not activated, then those LVs still not activated during
system boot.

This, for example, breaks setups where initramfs is generated with
dracut and LVs selectively activated using "rd.lvm.lv" kernel cmdline
option.

-- 
Alexander Tsoy


