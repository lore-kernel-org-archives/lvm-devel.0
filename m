From: Jim Meyering <jim@meyering.net>
Date: Wed, 12 Sep 2007 20:29:25 +0200
Subject: fix for link pthread-related link failure on Debian
In-Reply-To: <1189620953.4435.2.camel@linux-cxyg> (Dave Wysochanski's message
	of "Wed\, 12 Sep 2007 14\:15\:53 -0400")
References: <877imvsty8.fsf@rho.meyering.net>
	<1189620953.4435.2.camel@linux-cxyg>
Message-ID: <873axjrb3u.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> wrote:

> On Wed, 2007-09-12 at 18:57 +0200, Jim Meyering wrote:
>> FYI, I've just fixed in LVM the problem I fixed in device-mapper
>> not long ago: link failure (due to unsatisfied -lpthread references)
>> when building with --enable-static_link.  I noticed it on a Debian
>> unstable system.  The patch will show up here in a few minutes:
>>
>>   http://git.et.redhat.com/?p=lvm2.git
>>
>
> This causes a build script I have to fail on my rhel4u5/6 xen node.
> Might be a problem in my script but I've been using it successfully for
> quite a while.

Thanks for the heads-up.
The generated configure script had vestiges of an upcoming
patch (which works fine in my polluted work area, btw, but
nowhere else), and since there is no rule to regenerate configure
when configure.in is newer, I mistakenly checked in the stale copy.

I've just rerun autoconf and committed the new, regenerated file.
This is one of the reasons I really like to have complete and
accurate dependencies.  Does anyone know why we lack this particular one?

Would anyone object to my adding the missing rule?


