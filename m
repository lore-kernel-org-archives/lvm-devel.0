From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 10:44:02 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87ipmkxvlt.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<4EC2E670.6000208@redhat.com>
	<20111116000020.GA3294@agk-dp.fab.redhat.com>
	<87ipmkxvlt.fsf@aldalome.int.mornfall.net.>
Message-ID: <4EC385E2.1000105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16.11.2011 10:30, Petr Rockai napsal(a):
> Alasdair G Kergon<agk@redhat.com>  writes:
>> - real problem is the *calculation* must be going wrong if one
>> extend is insufficient to solve the problem!
>
> No, the real problem is that the snapshot is being filled and reaches
> the threshold again, after first extension is done. Nothing wrong with
> calculation.

Calculation should happen per every 5% increase.

Yet the logic there is IMHO not the best abd I'd say there are couple things 
to improve.

Recalc is made on every 5% increase and 10 second delay is relatively
way too long time - when you could easily write over 100MB/s these days even
on very low level laptops - and better hardware may easily reach over 400MB/s

(We already have reports from users, which needed to use very low watermark
level to catch fast writing apps overfilling snapshot)

I'm playing with something similar on thinp support,
and I think we need something smarted here - which works with relative sizes
(well thinp will sleep at least - why not making the same for snapshots ?)

Anyway - related to Petr's patch - I don't like value '6' -
I would put there i.e. 128 - so we could keep real errors sequential within 7 
bits ? and non-real-errors either 0 or > 127   (will we need more of these ?)


Zdenek


