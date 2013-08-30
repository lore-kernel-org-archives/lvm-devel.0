From: Oliver Rath <rath@mglug.de>
Date: Fri, 30 Aug 2013 11:32:50 +0200
Subject: lvrename changes link to direct /dev/dm-X
In-Reply-To: <522061EC.6090109@redhat.com>
References: <521F1A5F.9040805@mglug.de> <52206140.7060204@redhat.com>
	<522061EC.6090109@redhat.com>
Message-ID: <522066C2.7030502@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Am 30.08.2013 11:12, schrieb Zdenek Kabelac:
> [..]
> Sorry - here should be   '--enable-udev_sync'
> (And for built-in thin support you also need  '--with-thin=internal')
>

A "./configure --help | grep udev" figured it out for me ;-)

Regards,
Oliver


