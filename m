From: David Teigland <teigland@redhat.com>
Date: Thu, 11 May 2017 09:53:59 -0500
Subject: Is it reasonable to build lvmlockd in this way?
In-Reply-To: <a490c762-cf24-dffe-fce2-c9dc08fc1176@suse.com>
References: <87647df9-df19-8edd-1d60-7e99b9bcb12b@suse.com>
	<20170510163738.GA27800@redhat.com>
	<a490c762-cf24-dffe-fce2-c9dc08fc1176@suse.com>
Message-ID: <20170511145359.GA12960@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 11, 2017 at 10:21:06AM +0800, Eric Ren wrote:
> Hi!
> 
> On 05/11/2017 12:37 AM, David Teigland wrote:
> > On Wed, May 10, 2017 at 05:10:27PM +0800, Eric Ren wrote:
> > > Hi David,
> > > 
> > > Firstly, I really appreciate your work on lvmlockd feature. I've enabled it for openSUSE,
> > > and have testing on it, which works great.
> > > 
> > > But, we got a build problem on lvmlockd discussed here:
> > >      https://bugzilla.suse.com/show_bug.cgi?id=1037309
> > > 
> > > This is caused by the way openSUSE tries to build cluster-relative packages separately
> > > by splitting spec file into different ones, in order to avoid dependencies when building
> > > basic lvm packages:
> > >      https://build.opensuse.org/package/show/Base:System/lvm2
> > > 
> > > For cLVM, we can do it this way without problems. But, it cannot work for lvmlockd in this way,
> > > because main lvm tools(like vgcreate) will link to the empty version of lvmlockd functions
> > > (lockd_running_lock_type in lvmlockd.h).
> > > 
> > > Our package team insists that we should change lvmlockd to the clvm way so that we can
> > > build lvmlockd separately.   Before doing useless work, I really like to hear your advice first.
> > > 
> > > Any comments would be appreciated!
> > Hi, I'm a little out of my depth with build/packaging/distribution issues.
> > First, I think you need to build with --enable-lvmlockd-dlm|sanlock, and
> > provide the necessary bits of sanlock/dlm for building (the -devel
> > subpackages of dlm and sanlock.)  It sounds like there's some aversion to
> > doing this, but I don't see the problem.

> Sorry, I didn't make the problem clear. Yes, it worked well when lvm and
> lvmlockd were built together.
> The problem came up when our package team want to avoid dependencies on
> cluster-relative devel packages
> at *building time*. They split lvm2.spec into 3 spec files: lvm2.spec[1],
> lvm2-clvm.spec[2] and device-mapper.spec[3]:

That doesn't sound like a terrible problem.

> [1] https://build.opensuse.org/package/view_file/Base:System/lvm2/lvm2.spec?expand=1
> [2] https://build.opensuse.org/package/view_file/Base:System/lvm2/lvm2-clvm.spec?expand=1
> [3] https://build.opensuse.org/package/view_file/Base:System/lvm2/device-mapper.spec?expand=1
> 
> So, lvm tools are built in lvm2.spec without "BuildRequires" on clustering
> devels like corosync, dlm, sanlock,
> while lvmlockd is built in lvm2-clvm.spec with all clustering things.
> 
> As a result, lvm tools will pull in the empty functions in lvmlockd.h [4]
> because "LVMLOCKD_SUPPORT" is not defined.
> 
> [4] https://sourceware.org/git/?p=lvm2.git;a=blob;f=lib/locking/lvmlockd.h;h=8b282d8c698a2b3cc18c81b4c152dc7d0b9e3e9b;hb=HEAD#l98
> 
> So every command using functions in lvmlockd.h will fail, even though wdmd,
> sanlock, lvmlockd are all ready. For example:
> 
> tw1:~ # vgcreate --shared vgtest /dev/vdb
> 	Using a shared lock type requires lvmlockd.
> 	Failed to detect a running lock manager to select lock type.
> 
> lockd_running_lock_type() is inlined the empty version into lvm tool in this case.
> 
> I know it's tricky to build lvmlockd in the way above. But, they ask me:
> since lvm tools and cLVM can build this way, and run without problem, is it
> possible that lvm tools can be built without linking to lvmlockd functions?

I think they have it backward: clvm should have been done like lvmlockd.
clvm apparently requires them to build lvm *twice*, with/without clvm, and
the one built without cannot be used with.  For lvmlockd they can simply
build lvm once and use that one with or without lvmlockd.  That's much
better.

If they really want to build lvm twice, once without sanlock/dlm devel
packages around, and once with the devel packages, and then they want to
run the lvm binary from the first build with or without the lvmlockd
binary from the second build... that's comical but probably simple to do.
You would enable lvmlockd in configure of both builds, but skip compiling
the daemons/lvmlockd directory the first time, i.e. apply this patch the
first time you build, and drop it for the second build:

diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index ebbd740efa9c..f5e815839979 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -40,9 +40,9 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
   SUBDIRS += lvmpolld
 endif
 
-ifeq ("@BUILD_LVMLOCKD@", "yes")
-  SUBDIRS += lvmlockd
-endif
+# ifeq ("@BUILD_LVMLOCKD@", "yes")
+#  SUBDIRS += lvmlockd
+# endif
 
 ifeq ("@BUILD_LVMDBUSD@", "yes")
   SUBDIRS += lvmdbusd


