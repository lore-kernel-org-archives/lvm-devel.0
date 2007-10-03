From: Jim Meyering <jim@meyering.net>
Date: Wed, 03 Oct 2007 12:08:23 +0200
Subject: Re: LVM2/tools/fsadm Makefile.in
In-Reply-To: <20071003095830.GH18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Wed, 3 Oct 2007 10:58:30 +0100")
References: <20071003094658.15588.qmail@sourceware.org>
	<20071003095830.GH18444@agk.fab.redhat.com>
Message-ID: <873aws4ijs.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Wed, Oct 03, 2007 at 09:46:58AM -0000, meyering at sourceware.org wrote:
>> 	* tools/fsadm/Makefile.in (LVMLIBS): Define.
>> 	(fsadm): Link with $(LVMLIBS).
>
>>  fsadm: $(OBJECTS)
>> -	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
>> +	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
>
> fsadm is meant to be independent of LVM2 so should not be using LVMLIBS.
> What should be done to deal with this?

Ok.
A few ways to do that:

    Move last_path_component from util.c to an independent header and
    make it a static inline function, then simply include it from fsadm.c.

    Add a Makefile rule that extracts the definition from util.c,
    and perhaps adding #include <string.h>,
    and making the function static inline.

    A couple more.  but I have to run.


