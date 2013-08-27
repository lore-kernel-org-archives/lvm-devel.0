From: Oliver Rath <rath@mglug.de>
Date: Tue, 27 Aug 2013 15:03:05 +0200
Subject: thinpool-block-device exists twice after renaming
Message-ID: <521CA389.504@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

Im using here lvm2 (2.02.99) with Ubuntu 12.04 wiht LTS-Kernel-Stack
(3.8er Kernel).

I ecreated a volume group an in this volume group a thinpool. Then i
created thinpool devices from this pool. So far, so fine

The thinpool devices are links in /dev/myvg/tp-device-1 ->
/dev/mapper/myvg-tp-device-1.

These were also links to /dev/dm-X devices.

NOW i rename a tp-device. The result is en error "cannot rename ..", BUT
in /dev/myvg/ the links are renamed and pointing - which looks strange
to me - to block-devices in /dev/mapper/ instead of links.

These block-devices have the same maior/minor-ids at hte /dev/dm-X
devices, so now the renamed block-device exists twice.

Any ideas to solve this?

Regards
Oliver


