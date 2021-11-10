From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 10 Nov 2021 18:41:40 +0530
Subject: Need clarification
Message-ID: <CAFe+wq3SuywSq0OFKr+ND_OWP4cL2xFDGKipVOBvpJZ3SR3vFA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi LVM Team!
A very good day to you.

I have the following observation, and I need your inputs to understand behavior.

1/ create a volume group on a single block device.
2/ create a logical volume on the volume group.
3/ pump IO to the dm device
4/ while IOs are active, force kernel crash through the sysrq interface.

This results in a kernel hang. possibly because of IOs waiting to be
serviced still.
This behavior is seen over thin pool, thin device as well.

1/ Is this behavior known or understood well as to why the kernel does
not complete a shutdown?
2/ Is there any configuration with the lvm/dm layer that can allow the
kernel to proceed to complete shutdown and reboot failing those
incomplete IOs?

Please advise.

Thanks
LN


