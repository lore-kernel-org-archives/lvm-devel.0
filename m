From: Oliver Rath <rath@mglug.de>
Date: Fri, 20 Sep 2013 17:24:58 +0200
Subject: addendum [war Re: thinpool creation set links /dev/vgname/lvname to /dev/mapper again instead to /dev/dm-X]
In-Reply-To: <523C65B6.2070802@mglug.de>
References: <afe74e531402fe71d2c999f16c79e216@mglug.de>
	<523C65B6.2070802@mglug.de>
Message-ID: <523C68CA.9020202@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Im sorry,

the files in /dev/mapper are links, too. This was an old scenario here.
But the links in /dev/dmivg are pointing to /dev/mapper instead to /dev/dm-X

Regards,
Oliver


Am 20.09.2013 17:11, schrieb Oliver Rath:
> Additionally i have to say, that the devices are now created in
> /dev/mapper and not in /dev
> 
> Regards,
> Oliver
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


