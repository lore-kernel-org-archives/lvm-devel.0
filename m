From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 31 Jul 2013 10:14:16 +0200
Subject: Now I'm convinced about Linux
In-Reply-To: <284284.73974.bm@smtp132.mail.ir2.yahoo.com>
References: <999744.9869.bm@smtp104.mail.ir2.yahoo.com>
	<51F61D64.6070600@redhat.com>
	<284284.73974.bm@smtp132.mail.ir2.yahoo.com>
Message-ID: <51F8C758.50002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/30/2013 11:56 AM, Kevin Chadwick wrote:
> I have written a vendor and product specific rule which loads a key into
> truecrypt and then immediately unmounts the usb. Unfortunately later
> rules then remount the device. I want the rules to stop evaluation for
> just this device. GOTO seems to only apply to the current rules file
> (from the logs, the man page needs improving here) and would require
> creating another rules file in any case which should not be necessary.

Yes, GOTO applies only to current rule file...

> 
> I could edit the rules file which is doing the re-mounting but that is
> another packages rules file that I should not have to manage. Also if I
> know that there is no need to continue rule evaluation for a device
> then it is far cleaner to stop especially if it was an embedded system
> (it's not but these things should be thought about (properness, power
> to the user/dev)). The usual method is putting big fat warnings on and
> not crippling users, and also not updating the man pages in light of
> the online tutorials talking about last_rule. I hate to think of all the

...I fully understand your concerns. We (LVM) were exactly in the
same situation as we used the 'last_rule' option to skip all the udev
processing that was not suitable as LVM also has some devices which
should not be used for scanning etc. Unfortunately, it seems that at
that time, we were one of the small group of users of this 'last_rule',
so it was not a problem for udev to simply remove it...

> wasted devs and users time for this simple lack of consideration.
> OpenBSD man pages are brill and I'm sure this kind of problem wouldn't
> happen under their watch. I have never had to power up a web browser on
> OpenBSD atleast for anything simple.
> 
> Perhaps there is a way but I cannot see it from the man pages.
> Google seems to say all rules files are processed as one but that
> seems not to be the case?
> 

...well, GOTO applies only to current rule file (so yes, maybe the
documentation should be clearer about this - but that needs to be reported
for udev team).

> I'm not even sure this is the right list but you seemed to have
> committed the last_rule removal with concerns about Kays decision.
> 

(I suppose you mean this one: http://comments.gmane.org/gmane.linux.lvm.devel/2119)

Nope, it wasn't me who wanted removal of that 'last_rule' from udev :)
We used the 'last_rule' ourselves and I remember being angry about its
removal too. Now, we need to set variables within rules which other rules
check... and yes, I had to notify all the other maintainers that owned
those other udev rules to check for these variables to make a skip
(to be honest, I hate this solution, but there is nothing else I could
do with what udev provides to prevent the rules from being scanned or
processed by third-party rules - if I understand correctly, that's exactly
what you're hitting now as well).

> Fedora was one of the first unix-like systems I ever used playing with
> selinux when first introduced on Fedora (3 I think) but I can't see me
> ever installing it again. (I installed it a year or two ago to try
> out systemd and I'm about as far from a systemd or polkit and so udisks
> fan as you can get, technically and practically)
> 

Well, yes, some of these have their advantages and, surely, their disadvantages.
As for udisks and from our LVM point of view, that's exactly the one which
caused extra scans for devices which we didn't want to be scanned and so
I had to negotiate the solution with its maintainer (you can spot some
"DM_UDEV_DISABLE_..." flags being checked now in udisks rules - this is
exactly to prevent that scanning we don't want to).

And to be honest, we've spent quite some time to make all this udev integration
working, to solve all bugs that appeared as a consequence etc.

Thing with Fedora is that it tries to adopt the newest techniques available.
Other distros might be more conservative here... The best in Linux world is
that you can make a decision which distro fits your needs the best.

Anyway, now I can imagine the source of your problems and yes, it's OK
that you made your points. Though in this case, I need to redirect you
to udev/systemd team as I can't help much here...

Peter


