From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 17 Sep 2019 11:38:33 -0400 (EDT)
Subject: dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <20190917140632.GA3728@redhat.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
	<20190916180107.GA725@infradead.org>
	<127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
	<CAMeeMh9t4LBwJn_CPQgFNa_Tyj22fJYHK-4qAnyn0RXm9RzCnw@mail.gmail.com>
	<20190917140632.GA3728@redhat.com>
Message-ID: <alpine.LRH.2.02.1909171133100.1876@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Tue, 17 Sep 2019, Mike Snitzer wrote:

> On Tue, Sep 17 2019 at  9:56am -0400,
> John Dorminy <jdorminy@redhat.com> wrote:
> 
> >    I'm confused here:
> 
> >    >...and then it fails on activation because DM table load detects old (or
> >    missing) dm-crypt feature.
> >    >(There was no way to get dm target version before table load if module is
> >    not loaded.)
> >    >And I tried to avoid modprobe calls from libcryptsetup.
> > 
> >    I'm not understanding how this could work. Let's say there's a module
> >    providing target 'splice' which is currently unloaded. Then `dmsetup
> >    target-version splice` is unaware of the splice target, and thus reports
> >    nothing. So in order to get the proper version number, we do have to do a
> >    modprobe first.
> >    But, if the module providing splice *is* already loaded, `dmsetup targets`
> >    will report splice's version number already, so `dmsetup target-version
> >    splice` is a convenience instead of parsing `dmsetup targets` output?
> 
> dm_get_target_type() loads the requested module.  No userspace modprobe
> needed.

The reason why Milan wanted it is - that it is bad practice to call 
external processes from libraries. He doesn't want to call modprobe from 
libcryptsetup. So I created this patch that calls modprobe from the kernel 
ioctl.

Mikulas


