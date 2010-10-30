From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 30 Oct 2010 18:44:33 +0200
Subject: Patch for fsadm bz 64146
In-Reply-To: <20101029212639.GU29400@agk-dp.fab.redhat.com>
References: <4CCB2668.8020809@redhat.com>
	<20101029204456.GB26687@redhat.com>	<20101029205623.GD26687@redhat.com>
	<20101029212639.GU29400@agk-dp.fab.redhat.com>
Message-ID: <4CCC4B71.7050201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.10.2010 23:26, Alasdair G Kergon napsal(a):
>>> "Skipping fsck for device \"$VOLUME\" as filesystem is mounted on $MOUNTED"
>> "for" could be replaced with "on" or "of" too. ;)
>  
> What's fsck?
> 

I think the tool should be used by system admins - so they should not need the
long version 'filesystem check' - but if it's preferable to avoid shortcut
I'll switch ?

Do we consider now this as a final solution - or do you rather prefer 'non
zero' return code for this case (check of mounted fs). This would require
exec_cmd modification for status passing we've discussed.

I'd rather avoid switching between success/fail return code from the fsadm
command between releases.

Zdenek


