From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Apr 2010 23:32:06 +0200
Subject: [RFC PATCH] Reduce noise about missing devices.
Message-ID: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is not intended to be directly applied, but more to start a
discussion. One problem with our handling of missing devices is the huge
amount of log noise each missing device produces. In a single run of
lvconvert --repair, I get multiple screens of "read error" and "Couldn't
find device with uuid"...

The attached patch reduces that noise by only reporting these things
once per run. I have used two different approaches for read errors and
for uuid's. Neither is perfect...

Another possible approach (one that I would probably prefer) is to add a
global log_error_once to log.c that would maintain a dm_hash_table of
error messages and downgrade already-reported errors to log_debug or
log_very_verbose automatically. A few error paths could use this.

The downside of all these approaches is that this is sort of global
knowledge, but I guess that's hard to avoid. Presumably, adding a call
to erase the hashtable to _init_logging would solve most of the problems
with this. I suspect that threading a toolcontext pointer through
everything so it could be passed to logging functions is not a viable
option.

About the device read errors, I am ambivalent what exactly to report as
log_error. It makes sense to only report first error per device, but it
also makes sense to report all unique errors per device. The global
log_error_once approach would give the latter, which I think may be
actually preferable.

Opinions?

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: reduce-dup-errors.diff
Type: text/x-diff
Size: 3559 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100427/824c0fca/attachment.bin>
