From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 04 Apr 2010 23:03:16 -0400
Subject: [PATCH 6/6] RFC: Change lvm2app version number from 1 to 2.
In-Reply-To: <4BB5D77A.2090409@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-4-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-5-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-6-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-7-git-send-email-dwysocha@redhat.com>
	<4BB5D77A.2090409@redhat.com>
Message-ID: <1270436597.2495.25.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2010-04-02 at 13:39 +0200, Milan Broz wrote:
> On 04/01/2010 11:57 PM, Dave Wysochanski wrote:
> > This version number change reflects the memory handling change
> > for string-based pv/vg/lv string based attributes.
> 
> Maybe it is better idea to use VG mempool, maybe not for
> VG attributes.
> 
> But change it now, it means that application using
> calls which previously deallocates these attributes with dm_free
> will now crash, because the memory returned is now owned
> by library.
> 

Right it's not a "nice" change right now but as far as I know we have
one library user and I've been in touch with him.


> I really do not like changing API this way in every release...
> 

Do you think it is better to leave things as they are?

It has not been changed until now.  Plus, there is already an
inconsistency in the way memory is handled with the APIs that return
lists owned by lvm2app and the attribute APIs return memory owned by the
application.  

With things as they are now, in addition to the inconsistency, an
application could easily create memory leaks if for example it just
wants to display attributes with something like this:

printf("vg_name = %s", lvm_vg_get_name(vg));

instead, the proper code is:

char *vgname;
vgname = lvm_vg_get_name(vg);
printf ("vg_name = %s", vgname);
dm_free(vgname);

And this must be done for _every_ attribute.


> I see three API possibilities
> 
>  - define buffer parameter, so all memory allocations are
> in user application
> 
>  - return strings/parameters *CONST* and define that lvm2app
> owns memory
> 
>  - use dm_malloc, and require dm_free in user aplications.
> 

Right, those are the possibilities.  I had discussed this with the David
Zeuthen a few weeks ago and he seemed to be fine with the change as this
is how one of his other APIs work.  I can forward you the discussion
and/or confirm with him again.

There are pros and cons of each approach.  


> But please do not change this later!
> 
> It is extremely confusing for library users,
> no warning that API is not stable will not help here...
> 

Agreed.  But do you feel we should leave the current inconsistency? 

Given that we are still early in the library development, and there are
few users, I felt it was not out of the question to propose a change.


