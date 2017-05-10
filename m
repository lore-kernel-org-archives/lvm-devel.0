From: David Teigland <teigland@redhat.com>
Date: Wed, 10 May 2017 11:37:38 -0500
Subject: Is it reasonable to build lvmlockd in this way?
In-Reply-To: <87647df9-df19-8edd-1d60-7e99b9bcb12b@suse.com>
References: <87647df9-df19-8edd-1d60-7e99b9bcb12b@suse.com>
Message-ID: <20170510163738.GA27800@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 10, 2017 at 05:10:27PM +0800, Eric Ren wrote:
> Hi David,
> 
> Firstly, I really appreciate your work on lvmlockd feature. I've enabled it for openSUSE,
> and have testing on it, which works great.
> 
> But, we got a build problem on lvmlockd discussed here:
>     https://bugzilla.suse.com/show_bug.cgi?id=1037309
> 
> This is caused by the way openSUSE tries to build cluster-relative packages separately
> by splitting spec file into different ones, in order to avoid dependencies when building
> basic lvm packages:
>     https://build.opensuse.org/package/show/Base:System/lvm2
> 
> For cLVM, we can do it this way without problems. But, it cannot work for lvmlockd in this way,
> because main lvm tools(like vgcreate) will link to the empty version of lvmlockd functions
> (lockd_running_lock_type in lvmlockd.h).
> 
> Our package team insists that we should change lvmlockd to the clvm way so that we can
> build lvmlockd separately.   Before doing useless work, I really like to hear your advice first.
> 
> Any comments would be appreciated!

Hi, I'm a little out of my depth with build/packaging/distribution issues.
First, I think you need to build with --enable-lvmlockd-dlm|sanlock, and
provide the necessary bits of sanlock/dlm for building (the -devel
subpackages of dlm and sanlock.)  It sounds like there's some aversion to
doing this, but I don't see the problem.

Once it's built, we're putting the lvmlockd binary into a separate
lvm2-lockd subpackage.  When built with lvmlockd support, lvm will still
operate fine without lvmlockd present, it will just report an error if you
try to use it.  I think this is what some of your references suggest.  I
can understand wanting to avoid including lvmlockd/dlm/sanlock everywhere
that lvm itself is needed, but putting lvmlockd into a separate package
should avoid that.

Dave


