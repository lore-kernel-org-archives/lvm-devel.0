From: Bryn M. Reeves <breeves@redhat.com>
Date: Thu, 11 Nov 2021 16:22:13 +0000
Subject: Need clarification
In-Reply-To: <70b1de35-76e2-391d-9d8c-3752fb948f41@redhat.com>
References: <CAFe+wq3SuywSq0OFKr+ND_OWP4cL2xFDGKipVOBvpJZ3SR3vFA@mail.gmail.com>
	<70b1de35-76e2-391d-9d8c-3752fb948f41@redhat.com>
Message-ID: <YY1DNXFh+mmuHOCh@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 11, 2021 at 01:23:03PM +0100, Zdenek Kabelac wrote:
> Dne 10. 11. 21 v 14:11 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi LVM Team!
> > A very good day to you.
> > 
> > I have the following observation, and I need your inputs to understand behavior.
> > 
> > 1/ create a volume group on a single block device.
> > 2/ create a logical volume on the volume group.
> > 3/ pump IO to the dm device
> > 4/ while IOs are active, force kernel crash through the sysrq interface.
> > 
> > This results in a kernel hang. possibly because of IOs waiting to be
> > serviced still.
> > This behavior is seen over thin pool, thin device as well.
> > 
> > 1/ Is this behavior known or understood well as to why the kernel does
> > not complete a shutdown?
> > 2/ Is there any configuration with the lvm/dm layer that can allow the
> > kernel to proceed to complete shutdown and reboot failing those
> > incomplete IOs?
> > 
> > Please advise.
> 
> I'm pretty sure     'echo b > /proc/sysrq-trigger'  will reboot your kernel.

It sounds like they are using the 'c' sysrq command; this invokes a
crash (used to be just dereferencing a NULL pointer) and is commonly
used to test configurations like kdump, or automatic reboot on panic.

>From what the reporter is saying it sounds like that is not happening in
the described scenario although presumably it has been configured?

After the 'c' it's not possible to issue further sysrq commands via the
/proc interface, so the 'b' would have to be invoked via sysrq keyboard
commands.

> Other then that I'm not much sure I'm getting your point here.
> 
> You crash your kernel and then you are wondering why it's hang ??

If you have kdump enabled, or /proc/sys/kernel/panic is set to a value
that is > 0 then this is definitely not expected behaviour.

In this case it's often useful to enable keyboard sysrq (since those can
be issued following the 'echo c > /proc/sysrq-trigger'), and to carry
out a thread dump (sysrq-t) to print all stacks to the console. To be
useful this generally needs a serial console or some other mechanism to
capture the large volume of messages for analysis.

Regards,
Bryn.


