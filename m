From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 25 Nov 2009 16:45:58 +0000
Subject: [PATCH] Remove unnecessary / duplicate dm_list macros and functions.
In-Reply-To: <1259166460-10790-1-git-send-email-dwysocha@redhat.com>
References: <1259166460-10790-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20091125164558.GJ26546@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 25, 2009 at 11:27:40AM -0500, Dave Wysochanski wrote:
> These are no longer used by anyone.  The dm_list defines are all in
> libdevmapper.h and libdm/datastruct/list.c contains any function definitions.
> There is some code in "old-tests" that still use this but this code is not
> being maintained.
 
Ack.

If a full build works without these old files now, remove them; if anything
still doesn't, then it needs to be fixed.

Alasdair


