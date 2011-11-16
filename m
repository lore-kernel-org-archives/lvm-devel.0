From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Nov 2011 10:30:38 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <20111116000020.GA3294@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 16 Nov 2011 00:00:21 +0000")
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<4EC2E670.6000208@redhat.com>
	<20111116000020.GA3294@agk-dp.fab.redhat.com>
Message-ID: <87ipmkxvlt.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:
> - real problem is the *calculation* must be going wrong if one
> extend is insufficient to solve the problem!

No, the real problem is that the snapshot is being filled and reaches
the threshold again, after first extension is done. Nothing wrong with
calculation.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


