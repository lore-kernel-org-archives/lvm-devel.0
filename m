From: Petr Rockai <prockai@redhat.com>
Date: Tue, 25 Mar 2014 18:25:43 +0100
Subject: master - lvmetad: Wait at least 80s for the initial scan.
In-Reply-To: <5331A82E.5000906@suse.de> (Hannes Reinecke's message of "Tue, 25
	Mar 2014 09:00:46 -0700")
References: <20140325153912.1E68F60DAA@fedorahosted.org>
	<5331A82E.5000906@suse.de>
Message-ID: <87d2hachrc.fsf@aldalome.mornfall.net>
	(sfid-20140325_182544_331604_BCE0076B)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Hannes Reinecke <hare@suse.de> writes:
> Can't we have a configuration setting for this?
> I can imagine plenty of scenarios where the default value might not be
> applicable, being either to short or too long.

can you share such a scenario? This code path is currently hit in the
boot sequence (where a 90s timeout is already imposed by systemd, IIUIC)
and in the rare case where you change global_filter in lvm.conf. We hope
the boot code will be able to avoid it altogether, so eventually, the
only place where this can happen is when you modify global_filter and
then run two LVM commands in parallel. If the first takes more than 80s
to do its initial scanning, the second command will time out.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


