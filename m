From: Milan Broz <mbroz@redhat.com>
Date: Fri, 02 Apr 2010 13:39:38 +0200
Subject: [PATCH 6/6] RFC: Change lvm2app version number from 1 to 2.
In-Reply-To: <1270159052-1181-7-git-send-email-dwysocha@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>	<1270159052-1181-4-git-send-email-dwysocha@redhat.com>	<1270159052-1181-5-git-send-email-dwysocha@redhat.com>	<1270159052-1181-6-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-7-git-send-email-dwysocha@redhat.com>
Message-ID: <4BB5D77A.2090409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/01/2010 11:57 PM, Dave Wysochanski wrote:
> This version number change reflects the memory handling change
> for string-based pv/vg/lv string based attributes.

Maybe it is better idea to use VG mempool, maybe not for
VG attributes.

But change it now, it means that application using
calls which previously deallocates these attributes with dm_free
will now crash, because the memory returned is now owned
by library.

I really do not like changing API this way in every release...

I see three API possibilities

 - define buffer parameter, so all memory allocations are
in user application

 - return strings/parameters *CONST* and define that lvm2app
owns memory

 - use dm_malloc, and require dm_free in user aplications.

But please do not change this later!

It is extremely confusing for library users,
no warning that API is not stable will not help here...

Milan


