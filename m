From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:58:42 +0100
Subject: [PATCH 12/13] First cut at adding pv_obj_* APIs.
In-Reply-To: <1233607809-1087-13-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:50:08 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-10-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-11-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-12-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-13-git-send-email-dwysocha@redhat.com>
Message-ID: <874ozc75n1.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> Impelemnt pv_obj_get(), pv_obj_get_list(), pv_obj_get_attr_list() and
> pv_obj_get_attr_value().
>
> This is a first attempt at adding pv_obj_* APIs as outlined by
> http://fedoraproject.org/wiki/LVM/liblvm/api
>
> Why add another structure when we could use struct physical_volume
> and other internal structs?  At this point it is not clear but would
> provide us with the ability to more easily allocate and free handles,
> and would allow places to store things like the access mode and API
> errors without polluting the internal structures.
I don't say this is completely wrong, but the naming seems very baroque to me,
and not at all clear what it means, in relation to pv_t, lv_t and such. Also,
how does this relate to the idea that we want to push back the concept of a PV
as away from users as possible? I think Alasdair mentioned that on several
occasions -- PVs should become implicit, as opposed to explicit. Although it
might be a stretch for library. Not sure. What do you think?

As for internal structures, I suppose the major hurdle is the way we allocate
those in the toolcontext pool (and then maybe their complex interlinked
nature). I wouldn't say that another layer of, especially
heap-or-pool-allocated indirection will do any good. I think we already have
more than is good for us: the lvmcache is keeping a shadow copy of everything
already in an incompatible format from the struct volume_group and
friends. This happens to be the on-disk text format in a string buffer. I
believe this is also due to allocation and linking issues of the current struct
volume_group representation. So improving the situation with the struct
volume_group etc. would probably help the lvmcache, as well as the lvmlib
API. Maybe that would be a worthy investment then, instead of building up
another incompatible shadow structure?

Also, the patch seems to be duplicating a lot of code from previous patches? Or
were those for different kind of object (listing and checking attributes, eg.)?

[snip patch]

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


