From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Feb 2010 11:12:54 +0100
Subject: lvm and locales memory issue
In-Reply-To: <20100223094511.GW2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839743.8020909@redhat.com>
	<20100223091539.GV2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839C8F.5030103@redhat.com>
	<20100223094511.GW2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <4B83AA26.7050808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 23.2.2010 10:45, Jakub Jelinek wrote:
> On Tue, Feb 23, 2010 at 10:14:55AM +0100, Zdenek Kabelac wrote:
>> Well update of my rawhide usually more then 3/4 hour - so 6 minutes running in
>> background - that's really nothing.
> 
> Perhaps you don't care, but others do really care.
> 

Well the key point here is that >90% of users in fact really need 1-3 locales
on their system - thus for majority of user they could in fact spend 6
seconds in regenerating whole locale-archive file from scratch - and do not
need to transfer bigger glib-common and spend a lot of time with handling
100MB files during updates.

I simply believe that other distributions are more user friendly here.

Of course I could be mistaken and there could be a big demand from Fedora
users, to switch their locales to every single language, as nearly every
Fedora user runs a lot of localization tests on his machine all the time daily...

IMHO locale-archive data could be generated on the background during the whole
lengthy upgrade process - to me this looks similar to ldconfig or library
prelinking - thus the time is really not important - once the new
locale-archive is created its switched with the old file - where exactly do
you see the problem here?

In fact glibc-common my split locale-archive file into a separate rpm - for
those what want to safe the generation time and need all locales handy...

Another note - I do care a lot about the speed - but also about the space.

>> And quite frankly - during the update you need to update/recompile only
>> changed files - you could copy compiled & unchanged data to new file - thus in
>> fact it would takes couple seconds - unless each glibc update changes all i18n
>> locale definition, I doubt that - isn't that what the locale-archive.tmpl is
>> already doing?
> 
> There is a big tree of inclusions between the locale files, so you'd need to
> checksum them together with all the dependencies.  Anyway, that would still
> leave us with 6 minutes (on slow machines maybe half an hour) during Fedora
> installation.  I don't understand your sudden holy war against generated
> data in the distro, after all the locales aren't definitely the largest (but

Jakub please note - it's not a holly war against generated data in distro  -
this thread is about searching for solution with locking large mmaped files
into a memory for no point for mlockall() applications, when we should work in
limited 512MB xen/kvm guest.

You seem to be defending the point, that glibc has the right to mmap/lock
large pieces of memory into application memory space on the whatever benefit
it might bring in as the glibc knows what's 'the best' for the user - and user
application should have no control over this action - 'We' as lvm glibc user
tend to believe this is a wrong way -  we really cannot rewrite whole LVM just
because 'feature of the week' in glibc leads to such and such memory
allocation/waste - there should be some balance and control over this process.

In fact we even miss some table with list of function that are supposed to be
functional during mlockall().

As far as I'm aware we use only
open/read/write/str_funtion_handling/malloc/free/printf_familly  - at least
for lvm  case - we have some daemons which will need probably some inspection
for mlockall() case.


> is something everybody has installed).  Look at stuff like kdelibs-apidocs
> or asterisk-apidoc which are 650+ resp. 320+ MB of generated data.

I don't have them installed and I could live without such piece of bloat
easily.  But there is 'no life' without glibc-common ;)

Zdenek



