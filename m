From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 12 Sep 2007 14:15:53 -0400
Subject: fix for link pthread-related link failure on Debian
In-Reply-To: <877imvsty8.fsf@rho.meyering.net>
References: <877imvsty8.fsf@rho.meyering.net>
Message-ID: <1189620953.4435.2.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2007-09-12 at 18:57 +0200, Jim Meyering wrote:
> FYI, I've just fixed in LVM the problem I fixed in device-mapper
> not long ago: link failure (due to unsatisfied -lpthread references)
> when building with --enable-static_link.  I noticed it on a Debian
> unstable system.  The patch will show up here in a few minutes:
> 
>   http://git.et.redhat.com/?p=lvm2.git
> 

This causes a build script I have to fail on my rhel4u5/6 xen node.
Might be a problem in my script but I've been using it successfully for
quite a while.

Will ping you offline.  



