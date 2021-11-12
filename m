From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Fri, 12 Nov 2021 13:46:14 +0530
Subject: Need clarification
In-Reply-To: <YY1DNXFh+mmuHOCh@redhat.com>
References: <CAFe+wq3SuywSq0OFKr+ND_OWP4cL2xFDGKipVOBvpJZ3SR3vFA@mail.gmail.com>
	<70b1de35-76e2-391d-9d8c-3752fb948f41@redhat.com>
	<YY1DNXFh+mmuHOCh@redhat.com>
Message-ID: <CAFe+wq3wmyrSPgOPFor7X9O75r63HyqMWVLsmk-32ZjTAmzhvA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I am testing out recovery of the node when using dm devices as storage
drives and a kernel crash for any reason.
My expectation was the system would be able to sync and unmount
filesystems during a kernel crash forced through (echo c >
/proc/sysrq-trigger).
But the system did not complete shutdown and got hung.
It is generally true that if there is a kernel crash then the internal
structures may become inconsistent, but with forced reboot through
sysrq-trigger and option 'c', it is guaranteed none of the internal
structures are inconsistent, so I was surprised that sync/unmount over
dm devices
could not complete.

Based on your inputs, I was able to root cause the issue to incorrect
kdump configuration on the kernel.
It looks like my system has hit this bug
https://bugzilla.redhat.com/show_bug.cgi?id=1510654

Below are the background details.
1/ linux kernel version
[root at ip-10-13-11-45 ~]# cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"

[root at ip-10-13-11-45 ~]# uname -r
5.7.12-1.el7.elrepo.x86_64
[root at ip-10-13-11-45 ~]#



2/ kdump is configured with 'auto'
Linux kernel configuration defined as below with crashkernel=auto option.
menuentry 'CentOS Linux (5.7.12-1.el7.elrepo.x86_64) 7 (Core)' --class
centos --class gnu-linux --class gnu --class os --unrestricted
$menuentry_id_option
'gnulinux-5.7.12-1.el7.elrepo.x86_64-advanced-adf91006-76ef-4113-850a-090c2be36f20'
{
        load_video
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod ext2
        set root='hd0,msdos1'
        if [ x$feature_platform_search_hint = xy ]; then
          search --no-floppy --fs-uuid --set=root
--hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1
--hint-baremetal=ahci0,msdos1 --hint='hd0,msdos1'
691ac0a0-e4a2-40e3-b3ad-a720d630f49b
        else
          search --no-floppy --fs-uuid --set=root
691ac0a0-e4a2-40e3-b3ad-a720d630f49b
        fi
        linux16 /vmlinuz-5.7.12-1.el7.elrepo.x86_64
root=UUID=adf91006-76ef-4113-850a-090c2be36f20 ro crashkernel=auto
rhgb quiet biosdevname=0 net.ifnames=0
        initrd16 /initramfs-5.7.12-1.el7.elrepo.x86_64.img
}

Many thanks for your inputs.
Regards

On Thu, Nov 11, 2021 at 9:52 PM Bryn M. Reeves <breeves@redhat.com> wrote:
>
> On Thu, Nov 11, 2021 at 01:23:03PM +0100, Zdenek Kabelac wrote:
> > Dne 10. 11. 21 v 14:11 Lakshmi Narasimhan Sundararajan napsal(a):
> > > Hi LVM Team!
> > > A very good day to you.
> > >
> > > I have the following observation, and I need your inputs to understand behavior.
> > >
> > > 1/ create a volume group on a single block device.
> > > 2/ create a logical volume on the volume group.
> > > 3/ pump IO to the dm device
> > > 4/ while IOs are active, force kernel crash through the sysrq interface.
> > >
> > > This results in a kernel hang. possibly because of IOs waiting to be
> > > serviced still.
> > > This behavior is seen over thin pool, thin device as well.
> > >
> > > 1/ Is this behavior known or understood well as to why the kernel does
> > > not complete a shutdown?
> > > 2/ Is there any configuration with the lvm/dm layer that can allow the
> > > kernel to proceed to complete shutdown and reboot failing those
> > > incomplete IOs?
> > >
> > > Please advise.
> >
> > I'm pretty sure     'echo b > /proc/sysrq-trigger'  will reboot your kernel.
>
> It sounds like they are using the 'c' sysrq command; this invokes a
> crash (used to be just dereferencing a NULL pointer) and is commonly
> used to test configurations like kdump, or automatic reboot on panic.
>
> From what the reporter is saying it sounds like that is not happening in
> the described scenario although presumably it has been configured?
>
> After the 'c' it's not possible to issue further sysrq commands via the
> /proc interface, so the 'b' would have to be invoked via sysrq keyboard
> commands.
>
> > Other then that I'm not much sure I'm getting your point here.
> >
> > You crash your kernel and then you are wondering why it's hang ??
>
> If you have kdump enabled, or /proc/sys/kernel/panic is set to a value
> that is > 0 then this is definitely not expected behaviour.
>
> In this case it's often useful to enable keyboard sysrq (since those can
> be issued following the 'echo c > /proc/sysrq-trigger'), and to carry
> out a thread dump (sysrq-t) to print all stacks to the console. To be
> useful this generally needs a serial console or some other mechanism to
> capture the large volume of messages for analysis.
>
> Regards,
> Bryn.
>


