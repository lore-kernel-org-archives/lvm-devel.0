From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 11 Dec 2008 23:10:05 +0000
Subject: [PATCH 12/12] Remove init_full_scan_done(0) call after create_toolcontext().
In-Reply-To: <1228965978-19132-1-git-send-email-dwysocha@redhat.com>
References: <1228965978-19132-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081211231005.GM24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 10, 2008 at 10:26:18PM -0500, Dave Wysochanski wrote:
> _full_scan_done is initialized to 0 at compile time

But as with patch 10, its state should be considered 'undefined' when
create_toolcontext is called.
That initialisation does not include a full device scan (because many
commands that could be run would not require it) and on return from that
function you need it to be set to 0.

If the list of devices is read in from .cache then some code does not
need to scan but other code may still choose to scan.

> Is this a bug?  Why are we setting _full_scan_done = 0 here when we've
> already read the config file(s) for the 'scan' and other variables, then
> scanned the system for devices as shown above?  

We haven't scanned the system at that point.

This scanning code is certainly messy, but it will become 'legacy' when the
udev integration work is done, so it's not worth spending much time on.
(It's a while now since we've had a bug report against this scanning code
so it's best not to change the behaviour of code paths.)

Alasdair
-- 
agk at redhat.com


