From: Petr Rockai <prockai@redhat.com>
Date: Wed, 28 Apr 2010 17:18:40 +0200
Subject: [RFC PATCH] Reduce noise about missing devices.
In-Reply-To: <87k4rsa8fd.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 27 Apr 2010 23:32:06 +0200")
References: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
Message-ID: <87aasn8v1r.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Petr Rockai <prockai@redhat.com> writes:
> Another possible approach (one that I would probably prefer) is to add a
> global log_error_once to log.c that would maintain a dm_hash_table of
> error messages and downgrade already-reported errors to log_debug or
> log_very_verbose automatically. A few error paths could use this.
here's a patch that implements this. I think this is fairly reasonable
and could be checked in. Some minor function renaming might be
necessary.

Yours,
    Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: log_error_once.diff
Type: text/x-diff
Size: 5980 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100428/a4a1610f/attachment.bin>
