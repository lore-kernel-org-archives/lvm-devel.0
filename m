From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 15 Mar 2010 16:06:48 -0400 (EDT)
Subject: lv-shared
In-Reply-To: <20100315192925.GA29389@redhat.com>
References: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
	<20100315192925.GA29389@redhat.com>
Message-ID: <Pine.LNX.4.64.1003151600470.17728@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 15 Mar 2010, Mike Snitzer wrote:

> On Mon, Mar 15 2010 at  3:00pm -0400,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > Hi
> > 
> > Why did you hide the "lv-shared" volume? With this hidden, the size and 
> > percentage can't be seen.
> 
> You can still see it with: lvs -a
> 
> I'll have to revisit why I made it hidden (aside from the fact that the
> associated DM device is also hidden).  There was some subtle reason that
> had to do with the refactoring of associations when I eliminated the
> distinct ->shared_snapshot pointer (otherwise the vg_validate() method
> would fail).

I know it can be seen with lvs -a, but I think it's inconvenient for the 
admin:
- the admin won't see that there is a shared store taking up space
- the admin won't see that the origin is a shared snapshot, he sees 'o', 
but nothing that refers to that 'o'
- the percentage usage of the shared snapshot is hidden

I think this information is important and should be displayed with plain 
"lvs" command without any flags. (for example, the percentage usage is 
critical, because it can overflow) --- so "lv-shared" shouldn't be hidden.

Mikulas


