From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 Apr 2011 23:19:55 +0200
Subject: [PATCH] Improve handling of inconsistent precommit metadata
Message-ID: <87d3ktiz2c.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

working on RHBZ 651590 (failure to lock LV results in failure to repair
mirror after transient error), I have tracked the problem down to the
following sequence of events:

1) devices fail IO, triggering repair
2) dmeventd starts fixing up the mirror
3) during the downconversion, a new metadata version is written

--> the devices come back online here

4) the mirror device suspend/resume is called to update DM tables
5) during the suspend/resume cycle, *pre*-commit metadata is read;
   however, since the failed devices are now back online, we get back
   inconsistent set of precommit metadata and the whole operation fails

I am attaching a patch that relaxes the check that fails in step 5
above, namely by ignoring inconsistencies coming from PVs that are
marked MISSING.

The patch may fail to apply completely cleanly to current CVS, but it
should be good enough for review. I will check it in myself when
reviewed.

Yours,
   Petr

PS: There are couple more patches from me in the review backlog (most
importantly the vgreduce --removemissing --force refactor). If you have
a while, please do have a look.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: inconsistent-precommit-metadata.diff
Type: text/x-diff
Size: 6722 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110410/036c13cf/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
