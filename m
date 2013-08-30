From: Oliver Rath <rath@mglug.de>
Date: Fri, 30 Aug 2013 15:38:31 +0200
Subject: SLOVED [was "semop failed" while lvrename execution]
In-Reply-To: <52209E3B.8070006@redhat.com>
References: <52209D20.8090701@mglug.de> <52209E3B.8070006@redhat.com>
Message-ID: <5220A057.3010609@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek!

Great! This solved my issue: I copies the

./lvm2/udev/95-dm-notify.rules,in

to

/etc/udev/rules.d/95-dm-notify.rules

Reboot .. all is fine.

Thank you so much!

Regards,
Oliver


Am 30.08.2013 15:29, schrieb Zdenek Kabelac:
> {..[
>> What is todo?
> 
> 
> You probably have a mixture of udev rules in your debian
> There must be exactly 1 rule with this content:
> 
> 95-dm-notify.rules:ENV{DM_COOKIE}=="?*", RUN+="/usr/sbin/dmsetup
> udevcomplete $env{DM_COOKIE}"
> 
> (dmsetup udevcomplete)
> 
> I assume you have there 2 such rules - when you have just added upstream
> rules - and left in Debian broken rules.
> 
> Zdenek
> 
> 
> 
> -- 
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


