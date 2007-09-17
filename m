From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 17:03:25 +0100
Subject: strdup in str_list.c: why strdup rather than e.g., dm_pool_strdup?
In-Reply-To: <87sl5q3cfw.fsf@rho.meyering.net>
References: <87sl5q3cfw.fsf@rho.meyering.net>
Message-ID: <20070917160325.GG18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 07, 2007 at 02:08:35PM +0200, Jim Meyering wrote:
> I noticed the use of strdup in str_list.c, and wondered why that code
> isn't using dm_pool_strdup, since the list structure itself is allocated
> via dm_pool_alloc(mem,...
 
(Note that this code dates from 2004.)
strdup() should no longer be used (except in initialisation code):
we now have dm_strdup() instead that includes leak checking.

So firstly change it to dm_strdup().
Then the leak gets reported (eg pvdisplay a tagged PV).

So then change it to dm_pool_strdup() and things look OK.

Alasdair
-- 
agk at redhat.com


