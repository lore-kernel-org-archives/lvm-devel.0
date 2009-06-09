From: Petr Rockai <prockai@redhat.com>
Date: Tue, 09 Jun 2009 16:59:17 +0200
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
In-Reply-To: <20090609142912.6297.qmail@sourceware.org>
	(wysochanski@sourceware.org's message of "9 Jun 2009 14:29:12 -0000")
References: <20090609142912.6297.qmail@sourceware.org>
Message-ID: <874oupo3lm.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

wysochanski at sourceware.org writes:
> 	Various tools need to check for existence of a VG before doing something
> 	(vgsplit, vgrename, vgcreate).  Currently we don't have an interface to
> 	check for existence, but the existence check is part of the vg_read* call(s).
> 	This patch is an attempt to pull out some of that functionality into a
> 	separate function, and hopefully simplify our vg_read interface, and
> 	move those patches along.

I must have missed the patches on lvm-devel? Anyway, the tool patches create
conflicts with the vg_read patches that are pending for months. Could people
*please* stop changing conflicting parts of the code (see also Milan's patch
that changes the recovery code which conflicts with vg_read)? You can perfectly
fine create patches on top of the vg_read changes if they obviously overlap...

Alternatively, we could of course discard the vg_read patches, but I haven't
seen any NAKs yet...

(I guess you may consider this to be a NAK for the related commits, until the
situation is resolved somehow...)

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


