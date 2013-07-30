From: Kevin Chadwick <ma1l1ists@yahoo.co.uk>
Date: Tue, 30 Jul 2013 10:56:46 +0100
Subject: Now I'm convinced about Linux
In-Reply-To: <51F61D64.6070600@redhat.com>
References: <999744.9869.bm@smtp104.mail.ir2.yahoo.com>
	<51F61D64.6070600@redhat.com>
Message-ID: <284284.73974.bm@smtp132.mail.ir2.yahoo.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 29 Jul 2013 09:44:36 +0200
Peter Rajnoha wrote:

> On 07/26/2013 06:37 PM, Kevin Chadwick wrote:
> > Having a simple problem today that last_rule would solve just fine and
> > finding that I must edit extra files or manage a packages file is
> 
> You should not be pushed into editing udev rules unless you do something
> (very) extra. If something does not work correctly as expected, you
> should submit a bug report against the relevant distro/package.
> 
> What exactly is the nature of the problem that needs such a manual
> intervention? Also, what udev rules are we talking about exactly?
>

I have written a vendor and product specific rule which loads a key into
truecrypt and then immediately unmounts the usb. Unfortunately later
rules then remount the device. I want the rules to stop evaluation for
just this device. GOTO seems to only apply to the current rules file
(from the logs, the man page needs improving here) and would require
creating another rules file in any case which should not be necessary.

I could edit the rules file which is doing the re-mounting but that is
another packages rules file that I should not have to manage. Also if I
know that there is no need to continue rule evaluation for a device
then it is far cleaner to stop especially if it was an embedded system
(it's not but these things should be thought about (properness, power
to the user/dev)). The usual method is putting big fat warnings on and
not crippling users, and also not updating the man pages in light of
the online tutorials talking about last_rule. I hate to think of all the
wasted devs and users time for this simple lack of consideration.
OpenBSD man pages are brill and I'm sure this kind of problem wouldn't
happen under their watch. I have never had to power up a web browser on
OpenBSD atleast for anything simple.

Perhaps there is a way but I cannot see it from the man pages.
Google seems to say all rules files are processed as one but that
seems not to be the case?

> > quite convincing that they are right, especially the reason
> > "Inconsistent behaviour" when that is exactly what I expect to be able
> > to do on Unix and is so often made difficult just on Linux these days
> > and it seems especially in code mainly managed by RedHat, though I do
> > not a member of RedHat raising concerns about it.
> > 
> > I have tried creating /lib/udev/rules.d/zzz-arsewipingidiotfix.rules
> > with LABEL="very_end"
> > 
> > but adding GOTO="very_end" to earlier udev rules
> > (/etc/udev/rules.d/46-) is having no effect even after a udev restart?
> > 
> > Any ideas?
> > 
> 
> Please, provide more information about the problem and if the problem
> is related to LVM, then provide the LVM version as well please
> Also, is this Fedora or RHEL or are you trying to use upstream
> version directly?
> 

I'm not even sure this is the right list but you seemed to have
committed the last_rule removal with concerns about Kays decision.

Fedora was one of the first unix-like systems I ever used playing with
selinux when first introduced on Fedora (3 I think) but I can't see me
ever installing it again. (I installed it a year or two ago to try
out systemd and I'm about as far from a systemd or polkit and so udisks
fan as you can get, technically and practically)

> Peter

Thanks,
	Kc


