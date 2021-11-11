From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Nov 2021 13:23:03 +0100
Subject: Need clarification
In-Reply-To: <CAFe+wq3SuywSq0OFKr+ND_OWP4cL2xFDGKipVOBvpJZ3SR3vFA@mail.gmail.com>
References: <CAFe+wq3SuywSq0OFKr+ND_OWP4cL2xFDGKipVOBvpJZ3SR3vFA@mail.gmail.com>
Message-ID: <70b1de35-76e2-391d-9d8c-3752fb948f41@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10. 11. 21 v 14:11 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi LVM Team!
> A very good day to you.
> 
> I have the following observation, and I need your inputs to understand behavior.
> 
> 1/ create a volume group on a single block device.
> 2/ create a logical volume on the volume group.
> 3/ pump IO to the dm device
> 4/ while IOs are active, force kernel crash through the sysrq interface.
> 
> This results in a kernel hang. possibly because of IOs waiting to be
> serviced still.
> This behavior is seen over thin pool, thin device as well.
> 
> 1/ Is this behavior known or understood well as to why the kernel does
> not complete a shutdown?
> 2/ Is there any configuration with the lvm/dm layer that can allow the
> kernel to proceed to complete shutdown and reboot failing those
> incomplete IOs?
> 
> Please advise.

I'm pretty sure     'echo b > /proc/sysrq-trigger'  will reboot your kernel.

Other then that I'm not much sure I'm getting your point here.

You crash your kernel and then you are wondering why it's hang ??

When kernel crashes (Ooopses) - it's a situation that system has to be 
rebooted -  kernel cannot recover from such crash as its internal data 
structures cannot be trusted any more  (i.e. it's very much like if you 
user-space app core dumps and you don't expect, you will continue to run your 
text editor when you divide by 0).

Maybe you are not well describing what are you actually testing ?

My guess - maybe you are actually checking what happens on disk failure ?

Also you've completely forgetting to describe version of your kernel so there 
is simply way too many unknowns to give any sensible advice here...

Zdenek


